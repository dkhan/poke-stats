# finder = PokemonFinder.new(location: :work); finder.loop
# finder = PokemonFinder.new(location: :work, spiral: true, step_size: 0.001, step_limit: 29, skip_path_lookup: false); finder.loop
require 'poke-api'

class PokemonFinder
  def initialize(location:, spiral: false, step_size: 0.001, step_limit: 29, skip_path_lookup: false)
    @location = location
    @spiral = spiral
    @step_size = step_size
    @step_limit = step_limit
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
    places.each do |place|
      @lat = place[0]
      @lng = place[1]
      @place = place[2]

      puts "\n#{@place}: "

      begin
        find
      rescue => e
        puts e.inspect
      end
    end
  end

  def find_spiral
    places.each do |place|
      coords = generate_spiral(place[0], place[1], @step_size, @step_limit)

      print "\n#{place[2]}: "
      print_google_maps_path(coords, @skip_path_lookup)

      coords.each do |coord|
        @lat = coord[:lat]
        @lng = coord[:lng]

        begin
          find
        rescue => e
          puts e.inspect
        end
      end
    end
  end

  def loop
    while true
      @spiral ? find_spiral : find_all
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

  def generate_spiral(starting_lat, starting_lng, step_size, step_limit)
    coords = [{ lat: starting_lat, lng: starting_lng }]
    steps = 1
    x = 0
    y = 0
    d = 1
    m = 1
    rlow = 0.0
    rhigh = 0.0005

    while steps < step_limit
      while 2 * x * d < m && steps < step_limit
        x += d
        steps += 1
        lat = x * step_size + starting_lat + rand * ((rlow - rhigh) + rlow)
        lng = y * step_size + starting_lng + rand * ((rlow - rhigh) + rlow)
        coords << { lat: lat, lng: lng }
      end
      while 2 * y * d < m && steps < step_limit
        y += d
        steps += 1
        lat = x * step_size + starting_lat + rand * ((rlow - rhigh) + rlow)
        lng = y * step_size + starting_lng + rand * ((rlow - rhigh) + rlow)
        coords << { lat: lat, lng: lng }
      end

      d = -1 * d
      m += 1
    end

    coords
  end

  def print_google_maps_path(coords, skip_path_lookup = false)
    puts '' and return if skip_path_lookup

    url_string = 'http://maps.googleapis.com/maps/api/staticmap?size=400x400&path='
    coords.each { |c| url_string += "#{c[:lat]},#{c[:lng]}|" }

    path = HTTPClient.new.get("http://tinyurl.com/api-create.php?url=#{url_string[0..-2]}").body
    puts path
  end
end
