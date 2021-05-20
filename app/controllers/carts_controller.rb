class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  # GET /cart
  def show
    @guides = @cart.guides
  end

  private

  # Because users can only view their own cart, retrieve the current user's cart
  # (noting that user login is authenticated occurs before this step)
  def set_cart
    @cart = current_user.cart
  end
end
