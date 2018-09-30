Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }
  # Welcome Controller
  root 'welcome#index'
  # Dashboard Controller
  get "/dashboard/:page" => 'dashboard#show'
  get "dashboard/index" => 'dashboard#show'
end
