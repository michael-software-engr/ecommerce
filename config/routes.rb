Rails.application.routes.draw do
  # ... edited by app gen (other pages)
  get 'other_pages/map', as: 'map'
  get 'other_pages/email_form', as: 'email_form'
  post 'other_pages/email_send'
  get 'other_pages/under_construction', as: 'under_construction'

  # edited by app gen (landing page)
  get 'landing_page/index'
  root 'landing_page#index'

  resources :products, only: [:index, :show] do
    post 'buy', on: :collection
    post 'setup_purchase', on: :collection
  end

  # ... disabled by landing page edit
  # root 'products#index'

  # ... edited by app gen (user resource generation)
  get 'users/show'
  get 'users/index'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
