Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "quiz#choice", as: :authenticated_root
  end

  devise_scope :user do
    root "devise/sessions#new"
  end

  get "quiz/choice",         to: "quiz#choice",         as: :quiz_choice
  post "quiz/choice_answer", to: "quiz#choice_answer",  as: :quiz_choice_answer
  get "quiz/mistakes",       to: "quiz#mistakes",       as: :quiz_mistakes
  get "quiz/retry",          to: "quiz#retry_mistakes",  as: :quiz_retry
  post "quiz/retry_answer",  to: "quiz#retry_answer",    as: :quiz_retry_answer

  get  "favorites",                to: "favorites#index",   as: :favorites
  post "favorites/:vocabulary_id", to: "favorites#create",  as: :favorite_create
  delete "favorites/:vocabulary_id", to: "favorites#destroy", as: :favorite

  get "dashboard", to: "dashboard#index", as: :dashboard

  get "up" => "rails/health#show", as: :rails_health_check
end
