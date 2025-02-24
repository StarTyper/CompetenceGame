class Game < ApplicationRecord
  # Associations
  belongs_to :client
  belongs_to :user
  has_many :game_cards
  has_many :cards, through: :game_cards

  # Validations
  validates :name, presence: true
  validates :status, presence: true
  validates :client, presence: true
end
