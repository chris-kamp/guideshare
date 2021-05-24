class UserGuide < ApplicationRecord
  belongs_to :user
  belongs_to :guide
  # Ensure that a given user can only own one copy of a given guide
  validates :guide_id, uniqueness: {scope: :user_id, message: "already owned"}
end
