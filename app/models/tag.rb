class Tag < ApplicationRecord
  has_many :guide_tags, dependent: :destroy
  has_many :guides, through: :guide_tags
end
