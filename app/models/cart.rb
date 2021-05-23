class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_guides, dependent: :destroy
  has_many :guides, through: :cart_guides

  # Return the total price of guides in the cart
  def total
    return guides.sum(&:price)
  end

  # Get the username of the user who owns the cart
  def user_name
    return user.username
  end
end
