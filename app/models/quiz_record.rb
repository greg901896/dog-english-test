class QuizRecord < ApplicationRecord
  belongs_to :user
  belongs_to :vocabulary
end
