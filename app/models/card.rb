class Card < ApplicationRecord
  # Associations
  belongs_to :client, optional: true
  belongs_to :user, optional: true
  has_many :game_cards, dependent: :destroy

  # Validations
  validates :category, presence: true, inclusion: { in: %w[methodical social professional intuitive personal] }
  validates :positive, inclusion: { in: [true, false] }
  validates :name_german, length: { maximum: 255 }, allow_blank: true
  validates :name_english, length: { maximum: 255 }, allow_blank: true
  validates :explanation_german, length: { maximum: 1000 }, allow_blank: true
  validates :explanation_english, length: { maximum: 1000 }, allow_blank: true
  validates :image, length: { maximum: 255 }, allow_blank: true
end
