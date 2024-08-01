class Post < ApplicationRecord
  enum status: {published: 1, unpublished: 0}
  UPDATABLE_ATTRS = %i(caption content_url status).freeze
  belongs_to :user
  delegate :username, to: :user
  validates :caption, presence: true,
    length: {maximum: Settings.posts.max_caption}
  has_one_attached :content_url
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  scope :newest, ->{order(created_at: :desc)}
  scope :viewable_by, lambda {|user|
                        where("status = ? OR (status = ? AND user_id = ?)",
                              statuses[:published], statuses[:unpublished],
                              user.id)
                      }
  scope :feed, ->(user_ids){where(user_id: user_ids)}
end
