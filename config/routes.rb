Rails.application.routes.draw do
  # Welcome Controller
  root 'welcome#index'
  # Dashboard Controller
  get "/dashboard/:page" => 'dashboard#show'
end
