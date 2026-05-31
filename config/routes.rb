Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    invitations: "users/invitations"
  }

  root "home#index"

  # Organization settings
  resource :organization, only: %i[show update]

  # Projects with nested resources
  resources :projects do
    member do
      patch :archive
    end
    resources :tasks do
      resources :comments, only: %i[create destroy]
      member do
        patch :move  # for Kanban drag (future)
      end
    end
    resources :project_memberships, only: %i[create destroy], path: :members
    resource :settings, only: %i[show], controller: "project_settings"
  end

  # Org-level labels
  resources :labels, except: %i[show]

  # Notifications
  resources :notifications, only: %i[index] do
    collection { patch :mark_all_read }
    member     { patch :mark_read }
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
