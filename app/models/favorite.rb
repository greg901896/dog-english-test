class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :vocabulary

  validates :vocabulary_id, uniqueness: { scope: :user_id }
end
