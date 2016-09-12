require 'poke-api'
Poke::API::Logging.log_level = :UNKNOWN

class PokeApiService
  attr_accessor :lat, :lng

  def call
    if lat.blank? || lng.blank?
      raise "lat & lng are required"
    end

    client.store_lat_lng(lat, lng)

    client.get_map_objects(
      latitude: lat,
      longitude: lng,
      since_timestamp_ms: [0] * cell_ids.length,
      cell_id: cell_ids
    )

    client.call
  end

  private

  def client
    return @client if @client.present?

    @client = Poke::API::Client.new
    @client.login(ENV['PKGO_EMAIL'], ENV['PKGO_PASSWORD'], 'google')
    @client.activate_signature('/Users/dkhan/Git/poke-stats/files/encrypt.so')
    @client
  end

  def cell_ids
    @cell_ids ||= Poke::API::Helpers.get_cells(lat, lng)
  end
end
