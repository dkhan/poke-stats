CSV_FILENAME = "/Users/dkhan/trash/godkid_pokemons.csv".freeze

pokemons = []
resp.response[:GET_INVENTORY][:inventory_delta][:inventory_items].each do |i|
  unless i[:inventory_item_data][:pokemon_data].blank?
    pokemons << i[:inventory_item_data][:pokemon_data]
  end
end

pokemons.sort {|a, b| a[:creation_time_ms] <=> b[:creation_time_ms] }.each do |p|
  printf("%15s %15s %5s %5s %20s %20s %5s %5s %5s %5s %5s\n",
    p[:pokemon_id],
    p[:nickname],
    p[:cp],
    p[:stamina],
    p[:move_1],
    p[:move_2],
    p[:is_egg],
    p[:individual_attack],
    p[:individual_defense],
    p[:individual_stamina],
    p[:favorite])
end;1

CSV.open(CSV_FILENAME, "wb") do |csv|
  csv << pokemons.first.keys
  pokemons.each do |hash|
    csv << hash.values
  end
end
