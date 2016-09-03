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

  step_size = 0.0015
  step_limit = 2

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
      wild_pokemons.each do |pokemon|
        next if pokemon[:pokemon_data][:pokemon_id].to_s.in? common
        poke_data = "#{pokemon[:pokemon_data][:pokemon_id]}: http://maps.google.com/?q=#{pokemon[:latitude]},#{pokemon[:longitude]} --- #{Time.at(pokemon[:last_modified_timestamp_ms] / 1000)} (#{pokemon[:time_till_hidden_ms] / 1000})"

        path = "http://maps.google.com/?q=#{pokemon[:latitude]},#{pokemon[:longitude]}"
        time = Time.at(pokemon[:last_modified_timestamp_ms] / 1000).strftime("%m/%d/%Y %I:%M%p")
        time_left = Time.at(pokemon[:time_till_hidden_ms] / 1000).strftime("%M:%S")
        html_poke_data = "<a href='#{path}'>#{pokemon[:pokemon_data][:pokemon_id]}</a> #{time} (left: #{time_left})</br>\n"

          # 'lat' => pokemon[:latitude],
          # 'lng' => pokemon[:longitude],
          # 'time_stamp' => pokemon[:last_modified_timestamp_ms],
          # 'time_left' => pokemon[:time_till_hidden_ms] / 1000

        # Don't show the same pokemon again
        unless pokemon_data[pokemon[:encounter_id]]
          puts "#{poke_data}"
          File.open('pokemon_data.html', 'a') { |f| f.write "#{html_poke_data}\n" }
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
  [42.6733290, -71.1416420, "HOME"]
].freeze

File.open('pokemon_data.html', 'w')

PLACES.each do |coord|
  print "\n#{coord[2]}: "
  File.open('pokemon_data.html', 'a') { |f| f.write "\n</br>#{coord[2]}: " }

  client = Poke::API::Client.new

  # Set our location
  # client.store_location('Andover, MA')
  lat, lng = coord[0], coord[1]
  client.store_lat_lng(lat, lng)

  client.login('velasystems.owner@gmail.com', '4321Vela', 'google')

  client.activate_signature('/Users/dkhan/Git/poke-stats/files/encrypt.so')

  find_poi(client, client.lat, client.lng)
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

# Pony.mail(..., :attachments => {"foo.zip" => File.read("path/to/foo.zip"), "hello.txt" => "hello!"})
# echo "Test sending email from Postfix" | mail -s "Test Postfix" khandennis@gmail.com


