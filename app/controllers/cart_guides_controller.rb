class CartGuidesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart_guide, only: :destroy

  # POST /cart_guides
  # Creates a new CartGuide instance, effectively adding a guide to the relevant shopping cart obtained from params
  def create
    # Create a new CartGuide instance from params
    @cart_guide = CartGuide.new(cart_guide_params)

    # If creation succeeds, redirect back (or to the guides index as a fallback) and notify success
    if @cart_guide.save
      redirect_back(
        fallback_location: guides_path,
        notice: 'Guide was successfully added to cart.',
      )
      # If creation fails, redirect back (or to the guides index as a fallback) and alert that adding to cart failed
    else
      redirect_back(
        fallback_location: guides_path,
        alert: 'Item could not be added to cart.',
      )
    end
  end

  # DELETE /cart_guides/:id
  # Remove an item from a cart
  def destroy
    authorize(@cart_guide)
    @cart_guide.destroy
    redirect_to cart_url, notice: 'Guide was successfully removed from cart.'
  end

  # DELETE /cart_guides
  # Remove all items from current user's cart
  def destroy_all
    # Use custom CartGuide model scope to select all guides belonging to the current user.
    # User authentication occurs before this action, ensuring current_user will not be nil here.
    @cart_guides = CartGuide.in_cart_of(current_user)
    @cart_guides.destroy_all
    redirect_to cart_url, notice: 'All items cleared from cart.'
  end

  private

  # Use strong params to sanitise inputs required for CartGuide creation
  def cart_guide_params
    params.require(:cart_guide).permit(:cart_id, :guide_id)
  end

  # Retrieve a cart guide by ID using RESTful params
  def set_cart_guide
    @cart_guide = CartGuide.find(params[:id])
  end
end
