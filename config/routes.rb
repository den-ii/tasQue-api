Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api do 
    namespace :v1 do
      resources :auth, only: %i[index create] do
        collection do
          post :check_user
          post :verify_otp
          post :generate_otp
          post :sign_in
          post :modify_location
        end
      end
      resources :errands, only: %i[create destroy]
    end
  end

  # post "/api/v1/auth/check_user", to: "api/v1/auth#check_user"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "greetings#index"
  
end
