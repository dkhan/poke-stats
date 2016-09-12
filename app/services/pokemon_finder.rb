# finder = PokemonFinder.new(:work); finder.loop

class PokemonFinder
  def initialize(location, skip_path_lookup = true)
    @location = location
    @skip_path_lookup = skip_path_lookup
    @logged_pokemons = []
    @place, @lat, @lng = nil
  end

  def places
    @places ||= case @location
    when :home then PlacesHelper::HOME
    when :work then PlacesHelper::WORK
    when :eliza then PlacesHelper::ELIZA
    when :city then PlacesHelper::CITY
    when :castle then PlacesHelper::CASTLE
    when :point then PlacesHelper::POINT
    end
  end

  def service
    @service ||= PokeApiService.new
  end

  def response
    return @response if @response.present?

    service.lat = @lat
    service.lng = @lng
    @response = service.call
  end

  def wild_pokemons
    response.response[:GET_MAP_OBJECTS][:map_cells].map { |x| x[:wild_pokemons] }.flatten
  end

  def nearby_pokemons
    response.response[:GET_MAP_OBJECTS][:map_cells].map do |x|
      x[:nearby_pokemons].map! do |mon|
        crds = `python scripts/location_from_cell_id.py #{x[:s2_cell_id]}`
        mon.merge(
          latitude: crds.split(',').first,
          longitude: crds.split(',').last,
          last_modified_timestamp_ms: Time.now.to_i * 1000,
          time_till_hidden_ms: 0,
          encounter_id: nil
        )
      end
      x[:nearby_pokemons]
    end.flatten
  end

  def pokemons
    wild_pokemons + nearby_pokemons
  end

  def notify_slack(url, channel, text)
    payload = {
      channel: "#{channel}",
      username: 'poke-notifier',
      text: text,
      icon_emoji: ":ghost:"
    }.to_json
    cmd = "curl -s -X POST --data-urlencode 'payload=#{payload}' #{url} > /dev/null"
    system(cmd)
  end

  def find_all
    places.each do |coord|
      @lat = coord[0]
      @lng = coord[1]
      @place = coord[2]

      puts "\n#{@place}: "

      begin
        find
      rescue => e
        puts e.inspect
      end
    end
  end

  def loop
    while true
      find_all
      puts "-"*120
      sleep 60
    end
  end

  def find
    @response = nil
    pokemon_data = {}

    if response.response[:GET_MAP_OBJECTS] && response.response[:GET_MAP_OBJECTS][:map_cells]
      pokemons.each do |pokemon|
        pokemon_id = pokemon[:pokemon_id] || pokemon[:pokemon_data][:pokemon_id]
        #next if pokemon_id.to_s.in? PokemonData::COMMON

        path = "http://maps.google.com/?q=#{pokemon[:latitude]},#{pokemon[:longitude]}"
        disappears_at =
        if pokemon[:time_till_hidden_ms] > 0
          Time.at((pokemon[:last_modified_timestamp_ms] + pokemon[:time_till_hidden_ms]) / 1000).strftime("%m/%d/%Y %I:%M%p")
        else
          "UNKNOWN"
        end

        poke_data = "#{pokemon_id}: #{path} disappears: #{disappears_at}"
        html_poke_data = "<a href='#{path}'>#{pokemon_id}</a> disappears: #{disappears_at}</br>\n"
        slack_poke_data = "<#{path}|#{pokemon_id}> disappears @ #{disappears_at}"

        if pokemon_data[pokemon[:encounter_id]].blank? && !@logged_pokemons.include?(poke_data)
          puts "#{poke_data}"

          if pokemon_id.to_s.in?(PokemonData::RARE) && disappears_at != "UNKNOWN"
            # switch to LEGEND at night time, RARE otherwise
            if pokemon_id.to_s.in? PokemonData::RARE
              sms_fu = SMSFu::Client.configure(delivery: :pony, pony_config: Pony.options)
              sms_fu.deliver(ENV['GODKID_PHONE'], "at&t", poke_data) unless @location.in? [:eliza]
              sms_fu.deliver(ENV['KISSKA_PHONE'], "at&t", poke_data) if @location.in? [:eliza, :home]
            end

            notify_slack(ENV['GODKID_SLACK_URL'], @location, slack_poke_data)
            notify_slack(ENV['AUTODESK_SLACK_URL'], "boston-pokemongo", slack_poke_data) if @location == :work
          end
          @logged_pokemons << poke_data
        end

        pokemon_data[pokemon[:encounter_id]] = poke_data
      end
    end
  end
end
