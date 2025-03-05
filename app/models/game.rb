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

  def count_cards(category, positive: true)
    game_cards.joins(:card)
              .where(pile: 1, cards: { positive: positive, categoryenglish: category })
              .count
  end

  # Methods to count positive and negative cards for each category
  def cards_positive_methodical_count
    count_cards('methodical', positive: true)
  end

  def cards_negative_methodical_count
    count_cards('methodical', positive: false)
  end

  def cards_positive_intuitive_count
    count_cards('intuitive', positive: true)
  end

  def cards_negative_intuitive_count
    count_cards('intuitive', positive: false)
  end

  def cards_positive_personal_count
    count_cards('personal', positive: true)
  end

  def cards_negative_personal_count
    count_cards('personal', positive: false)
  end

  def cards_positive_social_count
    count_cards('social', positive: true)
  end

  def cards_negative_social_count
    count_cards('social', positive: false)
  end

  def cards_positive_professional_count
    count_cards('professional', positive: true)
  end

  def cards_negative_professional_count
    count_cards('professional', positive: false)
  end
end
