class CreatePokemons < ActiveRecord::Migration[5.0]
  def change
    create_table :pokemons do |t|
      t.string :external_id
      t.string :pokemon_id
      t.integer :cp
      t.integer :stamina
      t.integer :stamina_max
      t.string :move_1
      t.string :move_2
      t.string :deployed_fort_id
      t.string :owner_name
      t.boolean :is_egg
      t.float :egg_km_walked_target
      t.float :egg_km_walked_start
      t.integer :origin
      t.float :height_m
      t.float :weight_kg
      t.integer :individual_attack
      t.integer :individual_defense
      t.integer :individual_stamina
      t.float :cp_multiplier
      t.string :pokeball
      t.string :captured_cell_id
      t.integer :battles_attacked
      t.integer :battles_defended
      t.string :egg_incubator_id
      t.float :creation_time_ms
      t.integer :num_upgrades
      t.float :additional_cp_multiplier
      t.boolean :favorite
      t.string :nickname
      t.boolean :from_fort
      t.references :user

      t.timestamps
    end
  end
end
