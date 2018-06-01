Rails.application.routes.draw do
  root 'links#index'
  get "/:short_url", to: 'links#show'
  get "shortened/:short_url", to: 'links#shortened', as: :shortened

  post "/links/create"
  get "/links/get_original_url"
end
