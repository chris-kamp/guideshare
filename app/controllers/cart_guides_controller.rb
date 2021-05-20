class CartGuidesController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @cart_guide = CartGuide.new(cart_guide_params)
    # Redirect and notify success, or re-render "new" page with error messages if creation fails
    if @cart_guide.save
      redirect_back(fallback_location: guides_path,
                  notice: "Guide was successfully added to cart.")
    else
      redirect_back(fallback_location: guides_path, alert: "Item could not be added to cart.")
    end
  end

  def destroy
  end

  def cart_guide_params
    params.require(:cart_guide).permit(:cart_id, :guide_id)
  end
end
