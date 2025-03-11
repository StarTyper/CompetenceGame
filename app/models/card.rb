class Card < ApplicationRecord
  # Associations
  belongs_to :client
  belongs_to :user, optional: true
  has_many :game_cards, dependent: :destroy

  # Validations
  validates :category, presence: true, inclusion: { in: %w[methodical social professional intuitive personal] }
  validates :positive, inclusion: { in: [true, false] }
  validates :namegerman, length: { maximum: 255 }, allow_blank: true
  validates :nameenglish, length: { maximum: 255 }, allow_blank: true
  validates :explanationgerman, length: { maximum: 1000 }, allow_blank: true
  validates :explanationenglish, length: { maximum: 1000 }, allow_blank: true
  validates :image, length: { maximum: 255 }, allow_blank: true
end
