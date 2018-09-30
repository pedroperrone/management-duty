Rails.application.routes.draw do
  devise_for :admins, controllers: {
    sessions: 'admins/sessions',
    registrations: 'admins/registrations'
  }
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }
  # Welcome Controller
  root 'welcome#index'
  # Dashboard Controller
  get "/dashboard/:page" => 'dashboard#show'
  get "/dashboard" => 'dashboard#show'
end
