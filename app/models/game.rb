class Game < ApplicationRecord
  # Associations
  belongs_to :client
  belongs_to :user
  has_many :game_cards, dependent: :destroy
  has_many :cards, through: :game_cards

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :status, presence: true, inclusion: { in: %w[running finished] }
  validates :user, presence: true
  validates :count_positive, presence: true
  validates :count_negative, presence: true
  validates :pile, presence: true, inclusion: { in: [0, 1, 2] }
end
