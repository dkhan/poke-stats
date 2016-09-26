Rails.application.routes.draw do
  get 'pokemons/index'
  post 'pokemons/go'

  root 'pokemons#index'
end
