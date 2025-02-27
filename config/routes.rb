Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  # get home as home
  get "home" => "pages#home", as: :home

  # Add routes for games
  resources :games
  # resource for game play
  get "play" => "games#play", as: :play
  # resource for game remaining cards
  patch "remaining" => "games#remaining", as: :remaining
  # resource for game choosen cards
  patch "choosen" => "games#choosen", as: :choosen
  # resource for game rejected cards
  patch "rejected" => "games#rejected", as: :rejected
  # patch route for game plus
  patch "plus" => "games#plus", as: :plus
  # resource for game minus
  patch "minus" => "games#minus", as: :minus
  # resource for game cards choose
  patch "choose" => "games#choose", as: :choose
  # resource for game cards reject
  patch "reject" => "games#reject", as: :reject
  # resource for game next group
  patch "next_group" => "games#next_group", as: :next_group
  # resource for game finish
  get "finish" => "games#finish", as: :finish

  # resource for pages rules
  get "rules" => "pages#rules", as: :rules

  # Defines the root path route ("/")
  # root "posts#index"
end
