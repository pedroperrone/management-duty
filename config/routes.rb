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
  get 'dashboard/:page' => 'dashboard#show'
  get 'dashboard' => 'dashboard#show'

  # Admin controller
  get 'company/collaborators' => 'admins/invitations#index'


  namespace :users do
    resources :shift_exchanges, only: %i[create index]
    put 'shift_exchanges/:id/approve' => 'shift_exchanges#approve'
    put 'shift_exchanges/:id/refuse' => 'shift_exchanges#refuse'
    resources :searches, only: %i[index]
  end


  namespace :admins do
    resources :shift_exchanges, only: :index
    put 'shift_exchanges/:id/approve' => 'shift_exchanges#approve'
    put 'shift_exchanges/:id/refuse' => 'shift_exchanges#refuse'
  end

  # Shift controller
  resources :shifts

  put 'shift_partitions/:id' => 'shift_partitions#partitionate'
end
