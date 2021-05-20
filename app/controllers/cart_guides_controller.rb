class CartGuidesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart_guide, only: :destroy

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

  # DELETE /cart_guides/:id
  def destroy
    @cart_guide.destroy
    redirect_to cart_url, notice: 'Guide was successfully removed from cart.'
  end

  private

  def cart_guide_params
    params.require(:cart_guide).permit(:cart_id, :guide_id)
  end

  def set_cart_guide
    @cart_guide = CartGuide.find(params[:id])
  end
  
end
