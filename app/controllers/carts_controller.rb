class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  # GET /cart
  def show
    # Retrieve all CartGuide instances belonging to the relevant cart (ie. items in the cart). Use "includes" to
    # eager load the guides to which each CartGuide relates. Guide instances will be used to retrieve and display the
    #  title, price and other attributes of the guide in the view.
    @cart_guides = @cart.cart_guides.includes(:guide)

    # Retrieve guide_ids for each guide in the cart, to be passed to Stripe session on checkout.
    @guide_ids = @cart_guides.pluck(:guide_id)
  end

  private

  # Because users can only view their own cart, retrieve the current user's cart. Because user authentication occurs
  # first, no need to verify that current_user is not nil before accessing its cart.
  def set_cart
    @cart = current_user.cart
  end
end
