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

  # Admin controller
  get "/company/collaborators" => 'admins/invitations#index'

  # Shift controller
  get 'shift/new'
  get 'shift/update'
  post 'shift/create'
  get 'shift/destroy'
  get 'shift/edit'

  namespace :admins do
    resources :shift_exchanges, only: :index
    put 'shift_exchanges/:id/approve' => 'shift_exchanges#approve'
    put 'shift_exchanges/:id/refuse' => 'shift_exchanges#refuse'
  end
end
