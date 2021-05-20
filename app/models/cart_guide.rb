class CartGuide < ApplicationRecord
  belongs_to :cart
  belongs_to :guide

  # Ensure a given guide can only be added to a given cart once
  validates_uniqueness_of :guide_id, scope: :cart_id
end
