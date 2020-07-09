Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root to: 'pages#home'

  devise_for :users
  post 'pages', to: "pages#create"
  get 'index', to: 'pages#index'
  get 'residential', to: 'pages#residential'
  get 'corporate', to: 'pages#corporate'
  get 'quote', to: 'pages#quote'
  
  get 'new', to: 'pages#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end