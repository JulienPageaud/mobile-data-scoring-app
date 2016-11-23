Rails.application.routes.draw do

  devise_for :users, controllers: { registrations: "registrations" }
  devise_for :bank_users

  root to: 'pages#home'

  # Routes for customer's side of the application
  resources :users, only: [ :show, :edit, :update ] do
    resources :loans, only: [ :new, :create, :edit, :update, :show ]
  end

  # Routes for the bank's side of the application
  resources :bank_users, only:[:show] do
    resources :loans, only: [:index, :show, :edit, :update], controller: :bank_users
  end

  get 'client-profile/:id', to: 'bank_users#user_show'

  # User 'Current Situation' page
  get 'users/:id/status', to: 'users#status'

  # User 'Your Profile' page
  get 'users/:id/profile', to: 'users#profile'

  # User 'Share' page
  get 'users/:id/share', to: 'users#share'

end
