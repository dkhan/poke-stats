require 'pp'
require 'poke-api'

@location = :work

FILE_NAME = "/Users/dkhan/trash/pokemon_data_#{@location}.html".freeze
LOG_FILE_NAME = "/Users/dkhan/trash/log_#{@location}.html".freeze
DEFAULT_STEP_SIZE = 0.001
DEFAULT_STEP_LIMIT = 9

@step_size = DEFAULT_STEP_SIZE
@step_limit = DEFAULT_STEP_LIMIT
@skip_path_lookup = true

@godkid_slack_url = ENV['GODKID_SLACK_URL']
@autodesk_slack_url = ENV['AUTODESK_SLACK_URL']

@trainers = {
  'G0DKID' => {
    email: ENV['GODKID_EMAIL'],
    phone: ENV['GODKID_PHONE']
  },
  'K155KA' => {
    email: ENV['KISSKA_EMAIL'],
    phone: ENV['KISSKA_PHONE']
  }
}

@godkid_email = @trainers['G0DKID'][:email]
@godkid_phone = @trainers['G0DKID'][:phone]
@kisska_email = @trainers['K155KA'][:email]
@kisska_phone = @trainers['K155KA'][:phone]

case @location
when :home
  PLACES = [
    [42.671908980549155,-71.1379352968859, "Olde Berry Rd - S"],
    [42.67327460071642,-71.13728543638202, "Olde Berry Rd - N"],
    #[42.67190376384465,-71.13747111091996, "Olde Berry Rd 1"],
    [42.67350702447055,-71.13171516000095, "YMCA"], # MACHOKE
    [42.67377589019432,-71.13199367566865, "YMCA - N"], # GROWLITHE
    [42.67244721093195,-71.13329341287951, "YMCA - W"], # SQUIRTLE
    #[42.67202538324983,-71.13385044181574, "YMCA - W"], # SQUIRTLE
    [42.672494, -71.131730, "YMCA - SE"], # BULBASAUR
    #[42.67230482444437,-71.13375760371375, "YMCA - W"], # SQUIRTLE
    #[42.67348064940073,-71.13199367566865, "YMCA"], # DRATINI
    #[42.67312215978564,-71.13162232140185, "YMCA"], # DRATINI
    #[42.67340159017563,-71.13152948278112, "YMCA"], # DRAGONAIR
    #[42.673285593123396,-71.13171516000095, "YMCA"], # SQUIRTLE
    [42.685162329682996,-71.13644989988968, "Market Basket 1"], # SQUIRTLE
    [42.673285593123396,-71.13171516000095, "Market Basket 2"], # SQUIRTLE
    [42.68319619689961,-71.13617138733596, "Market Basket 3"], # DRATINI
    [42.68499893120908,-71.13635706239342, "Market Basket 4"], # LAPRAS
    #[42.68416080320546,-71.13663557481728, "Market Basket"], # SQUIRTLE
    [42.66499492351381,-71.14545503404499, "Stop & Shop - NW"], # DRATINI
    [42.665147, -71.144501, "Stop & Shop"], # SQUIRTLE
    #[42.66474701354118,-71.14573354009505, "Stop & Shop"], # DRATINI
    [42.663513215023904,-71.1449908568606, "McDonald's 1"], # SQUIRTLE
    [42.66384558670499,-71.14434100789065, "McDonald's 2"], # SQUIRTLE
    [42.663270763489955,-71.14443384352289, "McDonald's 3"], # GROWLITHE
    #[42.66375078772145,-71.14378399364129, "Papa Gino's"], # EEVEE
    [42.661277362484604,-71.14443384352289, "Whole Foods 1"], # SQUIRTLE
    [42.661572685946744,-71.14443384352289, "Whole Foods 2"], # GROWLITHE
    [42.661324445342316,-71.14601204594967, "Whole Foods 3"], # DRATINI
    [42.661960, -71.147573, "Post Office - W"], # GROWLITHE
    [42.662556, -71.146313, "Post Office - E"], # GROWLITHE
    [42.66301706074073,-71.14684756234064, "Post Office - N"], # DRATINI
    [42.656210356387355,-71.13895650410521, "Park - NW"], # GROWLITHE
    [42.65652669032813,-71.13951352512007, "Orange Leaf"], # LAPRAS
    [42.669708358324755,-71.14842575516631, "Main St/Park"], # DRAGONAIR
    [42.66753654811314,-71.14564070476675, "Washington Park Dr - N"], # DRAGONAIR
    [42.666429197838504,-71.14564070476675, "Washington Park Dr"], # SQUIRTLE
    [42.665685783164896,-71.14517652779949, "Washington Park Dr - S"], # DRATINI
    [42.66653490557712,-71.14452667913346, "Washington Park Dr - E"], # DRATINI
    [42.64755096571303,-71.13190083713435, "Phillips Academy"], # BULBASAUR
    #[42.647661830191915,-71.13125096678935, "Phillips Academy"], # BULBASAUR
    [42.66768645467054,-71.12354528065349, "Merrimack College"], # SQUIRTLE
    [42.661777492118034,-71.16300053270632, "Chadwick Cir"], # SQUIRLTE
    #[42.66164052824874,-71.16262920746927, "Chadwick Cir"], # SQUIRLTE
    #[42.6618935988856,-71.16281487013148, "Chadwick Cir"], # SCYTHER
    [42.66399966253818,-71.15826610976004, "Cindy Ln"], # EXEGGCUTE
    [42.65864318991865,-71.15325312950287, "West Middle School"], # SCYTHER
    [42.656277867973294,-71.15975142503243, "Miles Cir"], # GROWLITHE
    [42.660195, -71.161008, "Leah Way"], # SNORLAX
    [42.650666, -71.176255, "Wild Rose Dr"], # SNORLAX
    [42.673136638556706,-71.14341265037436, "Enmore St"], # EEVEE
    [42.67201337194757,-71.14461951472231, "Argyle St"], # BULBASAUR
    [42.65141684779342,-71.15418146397418, "Indian Ridge Res"], # GROWLITHE
    [42.66041390090952,-71.13719259908058, "Elm St"], # DRATINI
    [42.661928104305005,-71.13134380547488, "Pine St"], # SQUIRTLE
  ].freeze

  @step_size = 0.001
  @step_limit = 1

  @recipients = [@godkid_email, @kisska_email]

when :work
  PLACES = [
    [42.34470056212993,-71.03125131415162, "Mid"],
    [42.34481751970852,-71.02976552686681, "Here"],
    [42.34334376219247,-71.02679393632243, "Police"],
    [42.3442827507186,-71.02447236640192, "Trucks"],
    [42.34329627280826,-71.02521527018891, "Get out"],
    [42.34449834627182,-71.03440859443437 , "Parking"],
    [42.344520292868566,-71.03106559103237 , "Mid-"],
    [42.34467919590425,-71.03199420579584 , "Mid-left"],
    [42.34434495616482,-71.03264423489141 , "Mid-left+"],
  ].freeze

  @step_size = 0.001
  @step_limit = 5

  @recipients = [@godkid_email]

when :work
  PLACES = [
    [42.556519, -70.945009, "Office"],
    [42.558225, -70.942810, "Cemetery"],
    [42.559315, -70.940342, "Park"],
    [42.551823, -70.941806, "Mall - Kohl's"],
    [42.552716, -70.938598, "Mall - Best Buy"],
    [42.553933, -70.940626, "Mall - Marshalls"],
  ].freeze

  @step_size = 0.001
  @step_limit = 12

  @recipients = [@godkid_email, @kisska_email]

when :city
  PLACES = [
    [42.661182, -71.145568, "Andover"], # Whole Foods
  ].freeze

  @step_size = 0.0015
  @step_limit = 299

  @recipients = [@godkid_email]

when :castle
  PLACES = [
    [42.338598, -71.014065, "Parking"],
    [42.338812, -71.010429, "Fishing Pier"],
    [42.336751, -71.010139, "Lures"],
    [42.335097, -71.012290, "Lapras"],
    [42.337735, -71.012512, "Playground"],
    [42.330647, -71.015387, "Head Island"],

  ].freeze

  @step_size = 0.001
  @step_limit = 9

  @recipients = [@godkid_email]

when :point
  PLACES = [
    [42.627327, -71.159424, "200 Andover St"],
  ].freeze

  @step_size = 0.0015
  @step_limit = 29

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

def print_google_maps_path(coords, skip_path_lookup = false)
  raise if skip_path_lookup
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
  print_google_maps_path(coords, @skip_path_lookup)

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
        slack_poke_data = "<#{path}|#{pokemon_id}> disappears @ #{disappears_at}"

        # Don't show the same pokemon again
        if pokemon_data[pokemon[:encounter_id]].blank? && !logged_pokemons.include?(poke_data)
          puts "#{poke_data}"
          File.open(FILE_NAME, 'a') { |f| f.write "#{html_poke_data}\n" }

          if pokemon_id.to_s.in? rare
            # Pony.mail(
            #   :to => @recipients,
            #   :from => 'khandennis@gmail.com',
            #   :subject => "#{pokemon_id} @ #{@location}!!!",
            #   :body => poke_data,
            #   :html_body => html_poke_data
            # )

            if pokemon_id.to_s.in? rare # switch to legend at night time, rare otherwise
              sms_fu = SMSFu::Client.configure(:delivery => :pony, :pony_config => { :via => :sendmail })
              sms_fu.deliver(@godkid_phone, "at&t", poke_data) unless @location.in? [:eliza]
              sms_fu.deliver(@kisska_phone, "at&t", poke_data) if @location.in? [:eliza, :home, :point] # TODO: make it nice through recipients
            end

            notify_slack(@godkid_slack_url, @location, slack_poke_data)
            notify_slack(@autodesk_slack_url, "boston-pokemongo", slack_poke_data) if @location == :work
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

def notify_slack(url, channel, text)
  payload = {
    channel: "#{channel}",
    username: 'poke-notifier',
    text: text,
    icon_emoji: ":ghost:"
  }.to_json
  cmd = "curl -X POST --data-urlencode 'payload=#{payload}' #{url}"
  system(cmd)
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

    #begin
      client.login(ENV['PKGO_EMAIL'], ENV['PKGO_PASSWORD'], 'google')

      client.activate_signature('/Users/dkhan/Git/poke-stats/files/encrypt.so')

      logged_pokemons = find_poi(client, client.lat, client.lng, logged_pokemons)
    # rescue
    #   puts "Probably Google login problem"
    #   File.open(FILE_NAME, 'a') { |f| f.write "Google login problem</br>\n" }
    # end
  end;1

  log = File.read(FILE_NAME)
  File.open(LOG_FILE_NAME, 'a') do |handle|
    handle.puts log
  end

  # file = File.open(FILE_NAME)
  # contents = ""
  # file.each { |line| contents << line }

  # Pony.mail(
  #   :to => @recipients,
  #   :from => 'khandennis@gmail.com',
  #   :subject => "pokemons @ #{@location}",
  #   :body => 'See attachment',
  #   :html_body => contents,
  #   :attachments => { "pokemons.html" => log }
  # )

  puts "-"*120
  # sleep 300
end
