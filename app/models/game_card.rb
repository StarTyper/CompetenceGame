class GameCard < ApplicationRecord
  # Associations
  belongs_to :game
  belongs_to :card
end
