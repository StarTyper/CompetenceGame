class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  belongs_to :client
  has_many :games, dependent: :destroy
  has_many :game_cards, through: :games
  has_many :cards, through: :game_cards

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }, # rubocop:disable Layout/LineLength
                    uniqueness: true, length: { maximum: 255 }
  validates :role, presence: true, inclusion: { in: %w[admin manager employee guest] }
  validates :client, presence: true
  validates :language, presence: true, inclusion: { in: %w[german english] }

  # Set default role to guest and default client to "default"
  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.role ||= 'guest'
    self.client ||= Client.find_by(name: 'default')
  end
end
