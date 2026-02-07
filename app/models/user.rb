class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  has_many :quiz_records, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_vocabularies, through: :favorites, source: :vocabulary
end
