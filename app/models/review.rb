class Review < ApplicationRecord
  belongs_to :user
  belongs_to :guide
  validates :rating, presence: true
  validates :rating, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 5, message: "must be a number from 0 to 5"}
  validates :content, length: { maximum: 300 }
end
