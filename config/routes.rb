Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "quiz#index", as: :authenticated_root
  end

  devise_scope :user do
    root "devise/sessions#new"
  end

  get "quiz",                to: "quiz#index",          as: :quiz
  post "quiz/answer",        to: "quiz#answer",         as: :quiz_answer
  get "quiz/choice",         to: "quiz#choice",         as: :quiz_choice
  post "quiz/choice_answer", to: "quiz#choice_answer",  as: :quiz_choice_answer
  get "quiz/mistakes",       to: "quiz#mistakes",       as: :quiz_mistakes
  post "quiz/retry",         to: "quiz#retry_mistakes",  as: :quiz_retry

  get "dashboard", to: "dashboard#index", as: :dashboard

  get "up" => "rails/health#show", as: :rails_health_check
end
