class User < ApplicationRecord
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
end
