class Follow < ApplicationRecord
  belongs_to :follower, class_name: User.name
  belongs_to :followee, class_name: User.name
  validates :follower_id, presence: true
  validates :followee_id, presence: true
end
