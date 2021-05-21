class CartGuidePolicy < ApplicationPolicy
  # User can only delete cart items from user's own cart
  def destroy?
    user && record.cart.user == user
  end
end