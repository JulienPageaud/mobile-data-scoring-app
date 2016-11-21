Rails.application.routes.draw do
  devise_for :users, authentication_keys: [:mobile_number]
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
