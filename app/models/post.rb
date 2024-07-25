class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy
  scope :newest, ->{order(created_at: :desc)}
end
