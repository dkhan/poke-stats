require 'pp'
require 'poke-api'

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
  File.open('pokemon_data.html', 'a') { |f| f.write "<a href='#{path}'>Google path</a></br>\n" }
rescue
  puts ''
  File.open('pokemon_data.html', 'a') { |f| f.write "</br>\n" }
end

def find_poi(client, lat, lng)
  common = %w(WEEDLE KAKUNA PARAS SPEAROW MAGIKARP GOLDEEN PIDGEY PIDGEOTTO GASTLY ZUBAT RATTATA RATICATE PSYDUCK DROWZEE CATERPIE VENONAT KRABBY)
  rare = %w(SNORLAX LAPRAS)

  step_size = 0.0015
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
        # next if pokemon_id.to_s.in? common

        path = "http://maps.google.com/?q=#{pokemon[:latitude]},#{pokemon[:longitude]}"
        time = Time.at(pokemon[:last_modified_timestamp_ms] / 1000).strftime("%m/%d/%Y %I:%M%p")
        time_left = Time.at(pokemon[:time_till_hidden_ms] / 1000).strftime("%M:%S")
        poke_data = "#{pokemon_id}: #{path} --- #{time} (left: #{time_left})"
        html_poke_data = "<a href='#{path}'>#{pokemon_id}</a> #{time} (left: #{time_left})</br>\n"

        # Don't show the same pokemon again
        unless pokemon_data[pokemon[:encounter_id]]
          puts "#{poke_data}"
          File.open('pokemon_data.html', 'a') { |f| f.write "#{html_poke_data}\n" }

          if pokemon_id.to_s.in? rare
              sms_fu = SMSFu::Client.configure(:delivery => :pony, :pony_config => { :via => :sendmail })
              sms_fu.deliver("7742327536","at&t",poke_data)

              Pony.mail(
                :to => 'khandennis@gmail.com',
                :from => 'khandennis@gmail.com',
                :subject => "#{pokemon_id}!!!",
                :body => poke_data,
                :html_body => html_poke_data
              )
          end
        end

        pokemon_data[pokemon[:encounter_id]] = poke_data
      end
    end

    sleep 5
  end
end

Poke::API::Logging.log_level = :UNKNOWN

PLACES = [
  [42.673226, -71.132465, "YMCA"],
  [42.661743, -71.163384, "Kirkland Dr"],
  [42.648308, -71.182217, "Mobile Dunkin"],
  [42.661182, -71.145568, "Whole Foods"],
  [42.673362, -71.141776, "HOME"]
].freeze

while true do
  File.open('pokemon_data.html', 'w')

  PLACES.each do |coord|
    print "\n#{coord[2]}: "
    File.open('pokemon_data.html', 'a') { |f| f.write "\n</br>#{coord[2]}: " }

    client = Poke::API::Client.new

    # Set our location
    # client.store_location('Andover, MA')
    lat, lng = coord[0], coord[1]
    client.store_lat_lng(lat, lng)

    begin
      client.login('velasystems.owner@gmail.com', '4321Vela', 'google')

      client.activate_signature('/Users/dkhan/Git/poke-stats/files/encrypt.so')

      find_poi(client, client.lat, client.lng)
    rescue
      puts "Probably Google login problem"
      File.open('pokemon_data.html', 'a') { |f| f.write "Google login problem</br>\n" }
    end
  end;1

  file = File.open('pokemon_data.html')
  contents = ""
  file.each { |line| contents << line }

  Pony.mail(
    :to => 'khandennis@gmail.com',
    :from => 'khandennis@gmail.com',
    :subject => 'pokemons',
    :body => 'See attachment',
    :html_body => contents,
    :attachments => { "pokemons.html" => File.read("pokemon_data.html") }
  )

  sleep 600
end
