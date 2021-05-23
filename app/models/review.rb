class Review < ApplicationRecord
  belongs_to :user
  belongs_to :guide
  validates :rating, presence: true
  validates :rating, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 5, message: "must be a number from 0 to 5"}
  validates :content, length: { maximum: 300 }
  # Ensure no more than one review per user per guide is present
  validates_uniqueness_of :user_id, scope: :guide_id

  # Selects the most recent reviews, up to a limit of num_items
  scope :recent, ->(num_items) { order(created_at: :desc).limit(num_items) }

  # Get the username of the review's author
  def user_name
    return user.username
  end
end
