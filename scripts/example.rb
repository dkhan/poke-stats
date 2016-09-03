require 'poke-api'
require 'pp'

# Refer to README for information for setting up a Proxy if required

# Instantiate the client
client = Poke::API::Client.new

# Store your location, you can also store your lat/lng directly
# using client.store_lat_lng(lat, lng)
# or using client.lat = 10, client.lng = 10, client.alt = 10
# client.store_location('New York')

lat = 42.6733290
lng = -71.1416420
client.store_lat_lng(lat, lng)

# Use Google auth with 'username@gmail.com', 'password', 'google'
# Optionally set your Google Refresh token using client.refresh_token = 'my-token'
client.login('velasystems.owner@gmail.com', '4321Vela', 'google')

# Activate the encryption method to generate a signature
# Where path is the path to your encrypt .so/.dll
client.activate_signature('/Users/dkhan/Git/poke-stats/files/encrypt.so')

# Get cells
cell_ids = Poke::API::Helpers.get_cells(client.lat, client.lng)

# Construct map objects call
client.get_map_objects(
  latitude: client.lat,
  longitude: client.lng,
  since_timestamp_ms: [0] * cell_ids.length,
  cell_id: cell_ids
)

# Add more calls
client.get_player
client.get_inventory

# Call and view response
resp = client.call
pp resp
