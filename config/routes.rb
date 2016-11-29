Rails.application.routes.draw do

  get 'twilio/confirm_loan'

  devise_for :users, controllers: { registrations: "registrations", omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_for :bank_users

  root to: 'pages#home'

  # Routes for customer's side of the application
  resources :users, only: [ :show, :edit, :update ] do
    resources :loans, only: [ :new, :create, :edit, :update, :show ] do
      member do
        patch 'accept', to: 'loans#accept'
        put 'accept', to: 'loans#accept'
      end
    end

    # User 'Current Situation' page
    get 'status', to: 'users#status'

    # User 'Your Profile' page
    get 'profile', to: 'users#profile'

    # User 'Share' page
    get 'share', to: 'users#share'
  end


  # Routes for the bank's side of the application
  resources :bank_users, only:[:show] do
    resources :loans, only: [:index, :show, :update]
  end

  # About, Legal, Contact pages
  get 'about', to: 'users#about'
  get 'legal', to: 'users#legal'
  get 'contact', to: 'users#contact'

    # currently unused
  get 'client-profile/:id', to: 'bank_users#user_show'

  # Twilio routes
  post '/confirm_loan', to: 'twilio#confirm_loan'
end
