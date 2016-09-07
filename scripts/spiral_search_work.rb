require 'pp'
require 'poke-api'

FILE_NAME = '/Users/dkhan/trash/pokemon_data_work.html'.freeze
LOG_FILE_NAME = '/Users/dkhan/trash/pokemon_data_work_log.html'.freeze
PLACES = [
  [42.344369, -71.033217, "Front"], # current
  [42.344369, -71.031318, "Middle"],
  [42.344442, -71.029478, "Current"],
  [42.344471, -71.027747, "Back"],
  [42.344020, -71.024471, "Warf"],
].freeze

Poke::API::Logging.log_level = :UNKNOWN

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

def print_google_maps_path(coords)
  url_string = 'http://maps.googleapis.com/maps/api/staticmap?size=400x400&path='
  coords.each { |c| url_string += "#{c[:lat]},#{c[:lng]}|" }

  path = HTTPClient.new.get("http://tinyurl.com/api-create.php?url=#{url_string[0..-2]}").body
  puts path
  File.open(FILE_NAME, 'a') { |f| f.write "<a href='#{path}'>>>></a></br>\n" }
rescue
  puts ''
  File.open(FILE_NAME, 'a') { |f| f.write "</br>\n" }
end

def find_poi(client, lat, lng, logged_pokemons)
  common = %w(SHELLDER WEEDLE KAKUNA PARAS SPEAROW MAGIKARP GOLDEEN PIDGEY PIDGEOTTO PIDGEOT POLIWAG POLIWHIRL POLIWRATH CATERPIE METAPOD BUTTERFREE GASTLY ZUBAT RATTATA RATICATE PSYDUCK DROWZEE VENONAT KRABBY STARYU MAGNEMITE MAGNETON VOLTORB ELECTRODE TENTACOOL TENTACRUEL HORSEA VULPIX)
  rare = %w(SNORLAX LAPRAS GYARADOS KANGASKHAN DITTO ARTICUNO ZAPDOS MOLTRES MEWTWO MEW SQUIRTLE WARTORTLE BLASTOISE PIKACHU RAICHU GEODUDE GRAVLER GOLEM PONYTA RAPIDASH DRATINI DRAGONAIR DRAGONITE CHARMANDER CHARMELEON CHARIZARD BULBASAUR IVYSAUR VENUSAUR EKANS ARBOK GROWLITHE ARCANINE MACHOP MACHOKE MACHAMP MANKEY PRIMEAPE ONYX EXEGGCUTE EXEGGUTOR CHANSEY PORYGON AERODACTYL KABUTO KABUTOPS OMANYTE OMASTAR PINSIR MAGMAR MR_MIME TANGELA KOFFING WEEZING LICKTUNG HITMONCHAN HITMONLEE CUBONE MAROWAK)
  legend = %w(SNORLAX LAPRAS KANGASKHAN DITTO ARTICUNO ZAPDOS MOLTRES MEWTWO MEW)

  step_size = 0.0005
  step_limit = 9

  coords = generate_spiral(lat, lng, step_size, step_limit)
  print_google_maps_path(coords)

  pokemon_data = {}

  coords.each do |coord|
    lat = coord[:lat]
    lng = coord[:lng]
    client.store_lat_lng(lat, lng)

    cell_ids = Poke::API::Helpers.get_cells(lat, lng)

    client.get_map_objects(
      latitude: client.lat,
      longitude: client.lng,
      since_timestamp_ms: [0] * cell_ids.length,
      cell_id: cell_ids
    )

    resp = client.call
    # puts "\nSearching at lat: #{lat} lng: #{lng}"

    if resp.response[:GET_MAP_OBJECTS] && resp.response[:GET_MAP_OBJECTS][:map_cells]
      wild_pokemons = resp.response[:GET_MAP_OBJECTS][:map_cells].map { |x| x[:wild_pokemons] }.flatten
      nearby_pokemons = resp.response[:GET_MAP_OBJECTS][:map_cells].map do |x|
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

      (wild_pokemons + nearby_pokemons).each do |pokemon|
        pokemon_id = pokemon[:pokemon_id] || pokemon[:pokemon_data][:pokemon_id]
        next if pokemon_id.to_s.in? common

        path = "http://maps.google.com/?q=#{pokemon[:latitude]},#{pokemon[:longitude]}"
        disappears_at =
        if pokemon[:time_till_hidden_ms] > 0
          Time.at((pokemon[:last_modified_timestamp_ms] + pokemon[:time_till_hidden_ms]) / 1000).strftime("%m/%d/%Y %I:%M%p")
        else
          "UNKNOWN"
        end
        poke_data = "#{pokemon_id}: #{path} disappears: #{disappears_at}"
        html_poke_data = "<a href='#{path}'>#{pokemon_id}</a> disappears: #{disappears_at}</br>\n"

        # Don't show the same pokemon again
        if pokemon_data[pokemon[:encounter_id]].blank? && !logged_pokemons.include?(poke_data)
          puts "#{poke_data}"
          File.open(FILE_NAME, 'a') { |f| f.write "#{html_poke_data}\n" }

          if pokemon_id.to_s.in? rare
            Pony.mail(
              :to => 'khandennis@gmail.com',
              :from => 'khandennis@gmail.com',
              :subject => "#{pokemon_id}!!!",
              :body => poke_data,
              :html_body => html_poke_data
            )

            if pokemon_id.to_s.in? rare # switch to legend at night time
              sms_fu = SMSFu::Client.configure(:delivery => :pony, :pony_config => { :via => :sendmail })
              sms_fu.deliver("7742327536","at&t",poke_data)
              # sms_fu.deliver("5088735603","at&t",poke_data)
            end

          end
          logged_pokemons << poke_data
        end

        pokemon_data[pokemon[:encounter_id]] = poke_data
      end
    end

    sleep 5
  end

  logged_pokemons
end

logged_pokemons = []

while true do
  File.open(FILE_NAME, 'w')

  PLACES.each do |coord|
    print "\n#{coord[2]}: "
    File.open(FILE_NAME, 'a') { |f| f.write "\n</br>#{coord[2]}: " }

    client = Poke::API::Client.new

    # Set our location
    # client.store_location('Andover, MA')
    lat, lng = coord[0], coord[1]
    client.store_lat_lng(lat, lng)

    begin
      client.login('velasystems.owner@gmail.com', '4321Vela', 'google')

      client.activate_signature('/Users/dkhan/Git/poke-stats/files/encrypt.so')

      logged_pokemons = find_poi(client, client.lat, client.lng, logged_pokemons)
    rescue
      puts "Probably Google login problem"
      File.open(FILE_NAME, 'a') { |f| f.write "Google login problem</br>\n" }
    end
  end;1

  log = File.read(FILE_NAME)
  File.open(LOG_FILE_NAME, 'a') do |handle|
    handle.puts log
  end

  file = File.open(FILE_NAME)
  contents = ""
  file.each { |line| contents << line }

  Pony.mail(
    :to => 'khandennis@gmail.com',
    :from => 'khandennis@gmail.com',
    :subject => 'pokemons',
    :body => 'See attachment',
    :html_body => contents,
    :attachments => { "pokemons.html" => log }
  )

  puts "-"*120
  # sleep 300
end
