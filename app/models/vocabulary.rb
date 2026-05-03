class Vocabulary < ApplicationRecord
  SUGGESTED_CATEGORIES = %w[rails general database frontend backend devops].freeze

  has_many :quiz_records, dependent: :destroy
  has_many :favorites, dependent: :destroy

  validates :english, presence: true, uniqueness: true
  validates :chinese, presence: true
  validates :category, length: { maximum: 50 }, allow_blank: true
  validates :difficulty, inclusion: { in: 1..3 }

  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  scope :by_difficulty, ->(diff) { where(difficulty: diff) if diff.present? }
  scope :active, -> { where(active: true) }

  def self.category_options
    existing_categories = where.not(category: [nil, ""]).distinct.pluck(:category)
    (SUGGESTED_CATEGORIES + existing_categories).uniq.sort
  end
end
