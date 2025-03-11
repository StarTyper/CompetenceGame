class Game < ApplicationRecord
  # Associations
  belongs_to :client
  belongs_to :user
  has_many :game_cards, dependent: :destroy
  has_many :cards, through: :game_cards

  # Callbacks
  before_create :generate_unique_share_code
  before_create :generate_unique_challenge_code

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :status, presence: true, inclusion: { in: %w[running finished] }
  validates :user, presence: true
  validates :count_positive,  presence: true,
                              numericality: { only_integer: true, greater_than_or_equal_to: 1,
                                              less_than_or_equal_to: 50 }

  validates :count_negative,  presence: true,
                              numericality: { only_integer: true, greater_than_or_equal_to: 1,
                                              less_than_or_equal_to: 50 }
  validates :pile, presence: true, inclusion: { in: [0, 1, 2] }

  # Methods to count positive and negative cards
  def count_cards(category, positive: true)
    game_cards.joins(:card)
              .where(pile: 1, cards: { positive:, category: category })
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

  # Method to generate a unique share code
  def generate_unique_share_code
    loop do
      self.share_code = SecureRandom.hex(10) # Generate a random hex code
      break unless Game.exists?(share_code:) # Ensure it's unique
    end
  end

  # Method to regenerate the share code
  def regenerate_share_code
    generate_unique_share_code # Reuse the same method for unique code generation
    save # Save the game to update the share code
  end

  # Method to generate a unique challenge code
  def generate_unique_challenge_code
    loop do
      self.challenge_code = SecureRandom.hex(10) # Generate a random hex code
      break unless Game.exists?(challenge_code:) # Ensure it's unique
    end
  end

  # Method to regenerate the challenge code
  def regenerate_challenge_code
    generate_unique_challenge_code # Reuse the same method for unique code generation
    save # Save the game to update the challenge code
  end
end
