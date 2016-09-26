Rails.application.routes.draw do
  get 'pokemons/index'
  get 'pokemons/go'

  root 'pokemons#index'
end
