require 'poke-api'
require 'pp'

class PokemonParser
  def initialize(u, p, s)
    @u = u
    @p = p
    @s = s
  end

  def parse
    pokemons = []
    response.response[:GET_INVENTORY][:inventory_delta][:inventory_items].each do |i|
      unless i[:inventory_item_data][:pokemon_data].blank? || i[:inventory_item_data][:pokemon_data][:is_egg]
        pokemons << i[:inventory_item_data][:pokemon_data]
      end
    end
    pokemons.to_json
  end

  def response
    client = Poke::API::Client.new

    lat, lng = 42.344371, -71.029461 # office
    client.store_lat_lng(lat, lng)

    client.login(@u, @p, @s)

    client.activate_signature(File.join(Rails.root, "files/encrypt.so"))

    cell_ids = Poke::API::Helpers.get_cells(client.lat, client.lng)

    client.get_map_objects(
      latitude: client.lat,
      longitude: client.lng,
      since_timestamp_ms: [0] * cell_ids.length,
      cell_id: cell_ids
    )

    client.get_player
    client.get_inventory

    client.call
  end
end
