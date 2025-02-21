class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # validates first name, last name, email and role
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" },
                    uniqueness: true, length: { maximum: 255 }
  validates :role, presence: true, inclusion: { in: %w[admin manager employee guest] }

  # Set default role to guest
  after_initialize :set_default_role, if: :new_record?

  private

  def set_default_role
    self.role ||= 'guest'
  end
end
