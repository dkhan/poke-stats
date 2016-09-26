class PokemonsController < ApplicationController
  def index
  end

  def go
    @response = PokemonParser.new(params[:u], params[:p], params[:s]).response
    render template: "pokemons/pokemon_list", layout: "application"
  end
end
