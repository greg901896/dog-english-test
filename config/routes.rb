Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "quiz#index", as: :authenticated_root
  end
  root "devise/sessions#new"

  get "quiz",          to: "quiz#index",     as: :quiz
  post "quiz/answer",  to: "quiz#answer",    as: :quiz_answer
  get "quiz/mistakes", to: "quiz#mistakes",  as: :quiz_mistakes
  post "quiz/retry",   to: "quiz#retry_mistakes", as: :quiz_retry

  get "dashboard", to: "dashboard#index", as: :dashboard

  get "up" => "rails/health#show", as: :rails_health_check
end
