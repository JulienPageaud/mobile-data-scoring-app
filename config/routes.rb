Rails.application.routes.draw do

  devise_for :users, controllers: { registrations: "registrations", omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_for :bank_users

  root to: 'pages#home'

  ## Routes for customer's side of the application
  resources :users, only: [ :show, :edit, :update ] do
    resources :loans, only: [ :new, :create, :edit, :update, :show ] do
      member do
        patch 'accept', to: 'loans#accept'
        put 'accept', to: 'loans#accept'
      end
    end

    # User 'Current Loan Situation' page
    get 'status', to: 'users#status'

    # User profile page
    get 'profile', to: 'users#profile'

    # User 'Share' page
    get 'share', to: 'users#share'
  end


  ## Routes for the bank's side of the application
  resources :bank_users, only:[:show] do
    resources :loans, only: [:index, :show, :update]
    member do
      get 'applications', to: 'loans#applications'
      get 'outstanding', to: 'loans#outstanding'
      get 'declined', to: 'loans#declined'
      get 'repaid', to: 'loans#repaid'
      get 'portfolio', to: 'loans#portfolio'
    end
  end

  # Background Jobs dashboard
  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => 'sidekiq'
  end

  # About, Legal, Contact pages
  get 'about', to: 'users#about'
  get 'legal', to: 'users#legal'
  get 'contact', to: 'users#contact'

  # Twilio routes
  # get 'twilio/sign_up'
  # post '/sign_up', to: 'twilio#sign_up'
  # get 'twilio/confirm_loan'
  # post '/confirm_loan', to: 'twilio#confirm_loan'
  get 'twilio/sms_entry_point'
  post '/sms_entry_point', to: 'twilio#sms_entry_point'

  # currently unused
  get 'client-profile/:id', to: 'bank_users#user_show'
end
