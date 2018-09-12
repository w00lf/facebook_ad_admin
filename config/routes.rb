require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  authenticate :admin_user do
    mount Sidekiq::Web, at: '/sidekiq'
    Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
  end
  ActiveAdmin.routes(self)
  root to: "admin/dashboard#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
