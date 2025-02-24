class Client < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }

  # Associations
  has_many :users
  has_many :games, dependent: :destroy
  has_many :cards, dependent: :destroy
  has_many :game_cards, through: :cards
end
