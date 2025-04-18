Rails.application.routes.draw do
  devise_for :users, controllers: {
                                    registrations: 'users/registrations'
                                  }
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  # get home as home
  get "home" => "pages#home", as: :home

  post 'pages/alert_notice', to: 'pages#alert_notice', as: 'alert_notice'
  post 'pages/alert_alert' => 'pages#alert_alert', as: :alert_alert
  post 'pages/alert_error', to: 'pages#alert_error', as: 'alert_error'
  post 'pages/alert_success', to: 'pages#alert_success', as: 'alert_success'
  post 'pages/alert_info', to: 'pages#alert_info', as: 'alert_info'

  # Custom routes for games import/export
  get 'games/import_export_all_games' => 'games#import_export_all_games', as: :import_export_all_games
  get 'games/export_all_games' => 'games#export_all_games', as: :export_all_games
  post 'games/import_all_games' => 'games#import_all_games', as: :import_all_games

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

  # resource for game history
  get "history" => "games#history", as: :history

  # post share for game
  post 'games/:id/share' => 'games#share', as: :share_game
  # route for game share form
  get 'games/:id/share_form' => 'games#share_form', as: :share_form

  # resource for import_form action
  get "import_form" => "games#import_form", as: :import_form
  # resource for game import share code
  post "import", to: 'games#import', as: :import_game
  get 'verify_import/:share_code', to: 'games#verify_import', as: :verify_import
  # post 'import_game/:share_code', to: 'games#import', as: :import_game

  # post challenge for game
  post 'games/:id/challenge' => 'games#challenge', as: :challenge_game

  # resource for pages rules
  get "rules" => "pages#rules", as: :rules

  # resources for cards
  resources :cards
  # Defines the root path route ("/")
  # root "posts#index"
end
