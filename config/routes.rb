Rails.application.routes.draw do
  root 'links#new'
  get "/:short_url", to: 'links#show'
  get "shortened/:short_url", to: 'links#shortened', as: :shortened
  resources :links, only: :create
end
