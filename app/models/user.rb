class User < ApplicationRecord
  UPDATABLE_ATTRS = %i(username email bio password password_confirmation
                       profile_picture).freeze

  before_save :downcase_email!
  attr_accessor :remember_token

  validates :username, presence: true,
    length: {maximum: Settings.users.max_name}
  validates :password, presence: true,
    length: {minimum: Settings.users.min_password},
    format: {with: Settings.users.valid_password_regex,
             message: I18n.t("user.valid_password")}
  validates :email, presence: true,
    length: {maximum: Settings.users.max_email},
    format: {with: Settings.users.valid_email_regex},
    uniqueness: true
  has_one_attached :profile_picture
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
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post
  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def ransackable_attributes _auth_object = nil
      %w(username email created_at)
    end
  end

  def follow other_user
    following << other_user unless self == other_user
  end

  def unfollow other_user
    following.delete(other_user)
  end

  def following? other_user
    following.include?(other_user)
  end

  def like post
    likes.create(post_id: post.id)
  end

  def unlike post
    likes.find_by(post_id: post.id).destroy
  end

  def liked? post
    liked_posts.include?(post)
  end
  private
  def downcase_email!
    email.downcase!
  end
end
