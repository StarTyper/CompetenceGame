class Card < ApplicationRecord
  # Associations
  belongs_to :client
  has_many :game_cards, dependent: :destroy

  # Validations
  validates :categorygerman, presence: true
  validates :categoryenglish, presence: true
  validates :positive, inclusion: { in: [true, false] }
  validates :namegerman, presence: true, length: { maximum: 255 }
  validates :nameenglish, length: { maximum: 255 }, allow_blank: true
  validates :explanationgerman, length: { maximum: 1000 }, allow_blank: true
  validates :explanationenglish, length: { maximum: 1000 }, allow_blank: true
  validates :image, length: { maximum: 255 }, allow_blank: true
end
