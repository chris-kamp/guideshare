class CartGuide < ApplicationRecord
  belongs_to :cart
  belongs_to :guide

  # Ensure a given guide can only be added to a given cart once
  validates_uniqueness_of :guide_id, scope: :cart_id

  # Selects all CartGuides relating to a given guide
  scope :for_guide, ->(guide) { where(guide: guide) }
  # Selects all CartGuides in a given user's cart
  scope :in_cart_of, ->(user) { where(cart: user.cart) }


  # Get the title of the guide to which the cart_guide relates
  def title
    return guide.title
  end

  # Get the price of the guide to which the cart_guide relates
  def price
    return guide.price
  end
end
