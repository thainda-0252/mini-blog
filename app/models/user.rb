class User < ApplicationRecord
  UPDATABLE_ATTRS = [:username, :email, :profile_picture, :bio, :password,
                     :password_confirmation].freeze

  before_save :downcase_email!
  attr_accessor :remember_token

  validates :email, presence: true,
    format: {with: Settings.users.valid_email_regex},
    uniqueness: true
  has_secure_password
  has_many :posts, dependent: :destroy
  has_many :active_follows, class_name: Follow.name,
                                  foreign_key: :follower_id,
                                  dependent: :destroy
  has_many :passive_follows, class_name: Follow.name,
                                    foreign_key: :followee_id,
                                    dependent: :destroy
  has_many :following, through: :active_follows, source: :followee
  has_many :followers, through: :passive_follows, source: :follower
  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end
  end

  private
  def downcase_email!
    email.downcase!
  end
end
