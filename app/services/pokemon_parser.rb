require 'poke-api'
require 'pp'

class PokemonParser
  attr_accessor :user

  def initialize(u, p, s)
    @u = u
    @p = p
    @s = s
  end

  def parse
    pokemons = []
    return nil if response.blank? || user.blank?
    Pokemon.delete_all(user_id: user.id)
    response.response[:GET_INVENTORY][:inventory_delta][:inventory_items].each do |i|
      unless i[:inventory_item_data][:pokemon_data].blank? || i[:inventory_item_data][:pokemon_data][:is_egg]
        pokemon_data = i[:inventory_item_data][:pokemon_data]
        pokemons << pokemon_data
        Pokemon.create!(
          external_id: pokemon_data[:id],
          pokemon_id: pokemon_data[:pokemon_id],
          cp: pokemon_data[:cp],
          stamina: pokemon_data[:stamina],
          stamina_max: pokemon_data[:stamina_max],
          move_1: pokemon_data[:move_1],
          move_2: pokemon_data[:move_2],
          deployed_fort_id: pokemon_data[:deployed_fort_id],
          owner_name: pokemon_data[:owner_name],
          is_egg: pokemon_data[:is_egg],
          egg_km_walked_target: pokemon_data[:egg_km_walked_target],
          egg_km_walked_start: pokemon_data[:egg_km_walked_start],
          origin: pokemon_data[:origin],
          height_m: pokemon_data[:height_m],
          weight_kg: pokemon_data[:weight_kg],
          individual_attack: pokemon_data[:individual_attack],
          individual_defense: pokemon_data[:individual_defense],
          individual_stamina: pokemon_data[:individual_stamina],
          cp_multiplier: pokemon_data[:cp_multiplier],
          pokeball: pokemon_data[:pokeball],
          captured_cell_id: pokemon_data[:captured_cell_id],
          battles_attacked: pokemon_data[:battles_attacked],
          battles_defended: pokemon_data[:battles_defended],
          egg_incubator_id: pokemon_data[:egg_incubator_id],
          creation_time_ms: pokemon_data[:creation_time_ms],
          num_upgrades: pokemon_data[:num_upgrades],
          additional_cp_multiplier: pokemon_data[:additional_cp_multiplier],
          favorite: pokemon_data[:favorite],
          nickname: pokemon_data[:nickname],
          from_fort: pokemon_data[:from_fort],
          user_id: user.id
        )
      end
    end
    pokemons.to_json
  end

  def response
    return @response if @response.present?

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

    @response = client.call

    unless @response.blank?
      @user = User.find_or_create_by(username: @u, password: @p, auth_service: @s)
    end
  rescue => e
    logger.error(e)
    @response = nil
  ensure
    @response
  end
end
