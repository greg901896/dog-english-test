class Vocabulary < ApplicationRecord
  CATEGORIES = %w[rails general database frontend backend devops].freeze

  has_many :quiz_records, dependent: :destroy
  has_many :favorites, dependent: :destroy

  validates :english, presence: true, uniqueness: true
  validates :chinese, presence: true
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true
  validates :difficulty, inclusion: { in: 1..3 }

  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  scope :by_difficulty, ->(diff) { where(difficulty: diff) if diff.present? }
  scope :active, -> { where(active: true) }
end
