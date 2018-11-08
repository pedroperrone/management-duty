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
    resources :shift_exchanges, only: %i[index]
    put 'shift_exchanges' => 'shift_exchanges#approve', :as => :exchenge_approve
    put 'shift_exchanges' => 'shift_exchanges#refuse', :as => :exchenge_refuse
    post 'shift_exchanges' => 'shift_exchanges#create', :as => :shift_exchange
    resources :searches, only: %i[index]
  end


  namespace :admins do
    resources :shift_exchanges, only: :index
    put 'shift_exchanges' => 'shift_exchanges#approve', :as => :exchenge_approve
    put 'shift_exchanges' => 'shift_exchanges#refuse',  :as => :exchenge_refuse
  end

  #  Users Controller
  get 'users/:id' => 'users#show', :as => :user_show

  put 'shifts' => 'shifts#update', :as => :shift_update
  post 'shifts' => 'shifts#create', :as => :shift_create
  delete 'shifts' => 'shifts#destroy', :as => :shift_delete

  put 'shift_partitions' => 'shift_partitions#partitionate', :as => :shift_partition

end
