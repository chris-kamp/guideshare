class Review < ApplicationRecord
  belongs_to :user
  belongs_to :guide
  validates :rating, numericality: {in: 0..5}
  validates :content, length: { maximum: 300 }
end
