class UserGuide < ApplicationRecord
  belongs_to :user
  belongs_to :guide
  validates :guide_id, uniqueness: {scope: :user_id, message: "already owned"}
end
