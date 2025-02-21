class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  belongs_to :client

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" },
                    uniqueness: true, length: { maximum: 255 }
  validates :role, presence: true, inclusion: { in: %w[admin manager employee guest] }

  # Set default role to guest and default client to "default"
  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.role ||= 'guest'
    self.client ||= Client.find_by(name: 'default')
  end
end
