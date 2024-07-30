class Post < ApplicationRecord
  enum status: {published: 1, unpublished: 0}
  UPDATABLE_ATTRS = %i(caption content_url status).freeze
  belongs_to :user
  delegate :username, to: :user
  validates :caption, presence: true
  has_one_attached :content_url
  has_many :likes, dependent: :destroy
  scope :newest, ->{order(created_at: :desc)}
end
