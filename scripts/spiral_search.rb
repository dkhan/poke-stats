require 'pp'
require 'poke-api'

@location = :home

FILE_NAME = "/Users/dkhan/trash/pokemon_data_#{@location}.html".freeze
LOG_FILE_NAME = "/Users/dkhan/trash/log_#{@location}.html".freeze
DEFAULT_STEP_SIZE = 0.001
DEFAULT_STEP_LIMIT = 9

@step_size = DEFAULT_STEP_SIZE
@step_limit = DEFAULT_STEP_LIMIT

@trainers = {
  'G0DKID' => {
    email: 'khandennis@gmail.com',
    phone: '7742327536'
  },
  'K155KA' => {
    email: 'khanalena@gmail.com',
    phone: '5088735603'
  }
}

@godkid_email = @trainers['G0DKID'][:email]
@godkid_phone = @trainers['G0DKID'][:phone]
@kisska_email = @trainers['K155KA'][:email]
@kisska_phone = @trainers['K155KA'][:phone]

case @location
when :home
  PLACES = [
    [42.671630, -71.137836, "Olde Berry Rd"],
    [42.673483, -71.131838, "YMCA"],
    [42.684305, -71.136160, "Market Basket"],
    [42.664660, -71.144548, "Stop & Shop"],
    [42.663526, -71.144554, "McDonald's"],
    [42.661182, -71.145568, "Whole Foods"],
    [42.662406, -71.146854, "Post Office"],
    [42.666316, -71.146095, "Washington Park Dr (Dratini)"],
    [42.647901, -71.132127, "Phillips Academy"],
    [42.667983, -71.122917, "Merrimack College"],
    [42.666005, -71.157582, "Theodore Ave"],
    [42.661735, -71.163366, "Chadwick Cir"],
    [42.659940, -71.154742, "High School"],
    [42.665046, -71.170629, "West Elementary School"],
    [42.660104, -71.161190, "Leah Way"],
    [42.655388, -71.171757, "Cutler Rd"],
    [42.650666, -71.176256, "Wild Rose Dr"],
    [42.647629, -71.183184, "IRS"],
    [42.641835, -71.195241, "Patricia Cir"],
    [42.673548, -71.143517, "Enmore St"],
    #[42.673362, -71.141776, "HOME"],
  ].freeze

  @recipients = [@godkid_email, @kisska_email]

when :work
  PLACES = [
    [42.344369, -71.033217, "Front"],
    [42.344369, -71.031318, "Middle"],
    [42.344442, -71.029478, "Current"],
    [42.344471, -71.027747, "Back"],
    [42.344020, -71.024471, "Warf"],
  ].freeze

  @step_size = 0.0007
  @step_limit = 9

  @recipients = [@godkid_email]

when :eliza
  PLACES = [
    [42.556519, -70.945009, "Office"],
    [42.558225, -70.942810, "Cemetery"],
    [42.559315, -70.940342, "Park"],
    [42.551823, -70.941806, "Mall - Kohl's"],
    [42.552716, -70.938598, "Mall - Best Buy"],
    [42.553933, -70.940626, "Mall - Marshalls"],
  ].freeze

  @step_size = 0.0007
  @step_limit = 29

  @recipients = [@godkid_email, @kisska_email]

when :city
  PLACES = [
    [42.661182, -71.145568, "Andover"], # Whole Foods
  ].freeze

  @step_size = 0.0015
  @step_limit = 299

  @recipients = [@godkid_email]

when :point
  PLACES = [
    [42.556519, -70.945009, "Precise search"],
  ].freeze

  @step_size = 0.0005
  @step_limit = 49

  @recipients = [@godkid_email]
end

@recipients = @recipients.join(',')

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
  common = %w(SHELLDER WEEDLE KAKUNA BEEDRILL PARAS SPEAROW MAGIKARP GOLDEEN PIDGEY PIDGEOTTO PIDGEOT POLIWAG POLIWHIRL POLIWRATH CATERPIE METAPOD BUTTERFREE GASTLY ZUBAT RATTATA RATICATE PSYDUCK DROWZEE VENONAT KRABBY STARYU MAGNEMITE MAGNETON VOLTORB ELECTRODE TENTACOOL TENTACRUEL HORSEA VULPIX)
  rare = %w(SNORLAX LAPRAS GYARADOS KANGASKHAN DITTO ARTICUNO ZAPDOS MOLTRES MEWTWO MEW SQUIRTLE WARTORTLE BLASTOISE PIKACHU RAICHU GEODUDE GRAVLER GOLEM PONYTA RAPIDASH DRATINI DRAGONAIR DRAGONITE CHARMANDER CHARMELEON CHARIZARD BULBASAUR IVYSAUR VENUSAUR EKANS ARBOK GROWLITHE ARCANINE MACHOP MACHOKE MACHAMP MANKEY PRIMEAPE ONYX EXEGGCUTE EXEGGUTOR CHANSEY PORYGON AERODACTYL KABUTO KABUTOPS OMANYTE OMASTAR PINSIR MAGMAR MR_MIME TANGELA KOFFING WEEZING LICKTUNG HITMONCHAN HITMONLEE CUBONE MAROWAK SCYTHER)
  legend = %w(SNORLAX LAPRAS KANGASKHAN DITTO ARTICUNO ZAPDOS MOLTRES MEWTWO MEW)

  coords = generate_spiral(lat, lng, @step_size, @step_limit)
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
        disappears_at =
        if pokemon[:time_till_hidden_ms] > 0
          Time.at((pokemon[:last_modified_timestamp_ms] + pokemon[:time_till_hidden_ms]) / 1000).strftime("%m/%d/%Y %I:%M%p")
        else
          "UNKNOWN"
        end

        next if disappears_at == "UNKNOWN" # comment if want to see nearby

        poke_data = "#{pokemon_id}: #{path} disappears: #{disappears_at}"
        html_poke_data = "<a href='#{path}'>#{pokemon_id}</a> disappears: #{disappears_at}</br>\n"

        # Don't show the same pokemon again
        if pokemon_data[pokemon[:encounter_id]].blank? && !logged_pokemons.include?(poke_data)
          puts "#{poke_data}"
          File.open(FILE_NAME, 'a') { |f| f.write "#{html_poke_data}\n" }

          if pokemon_id.to_s.in? rare
            Pony.mail(
              :to => @recipients,
              :from => 'khandennis@gmail.com',
              :subject => "#{pokemon_id}!!!",
              :body => poke_data,
              :html_body => html_poke_data
            )

            if pokemon_id.to_s.in? rare # switch to legend at night time
              sms_fu = SMSFu::Client.configure(:delivery => :pony, :pony_config => { :via => :sendmail })
              sms_fu.deliver("7742327536", "at&t", poke_data)
              sms_fu.deliver("5088735603", "at&t", poke_data) if @location.in? [:eliza, :home] # TODO: make it nice through recipients
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
    :to => @recipients,
    :from => 'khandennis@gmail.com',
    :subject => 'pokemons',
    :body => 'See attachment',
    :html_body => contents,
    :attachments => { "pokemons.html" => log }
  )

  puts "-"*120
  # sleep 300
end
