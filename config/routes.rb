# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
                                 sign_in: 'login',
                                 sign_out: 'logout',
                                 registration: 'signup'
                               },
                     controllers: {
                       sessions: 'users/sessions',
                       registrations: 'users/registrations'
                     }
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[show index update] do
        collection do
          get :user_current
        end
      end
      resources :projects do
        member do
          put :assign_users
          post :restore
        end
        collection do
          get :grouped_by_status
          get :deleted_projects
        end
        resources :tasks, only: %i[create] do 
          collection do
            get :grouped_by_status
          end
        end
      end
      resources :tasks, expect: %i[create] do
        resources :comments, only: %i[create index]
      end
    end
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
