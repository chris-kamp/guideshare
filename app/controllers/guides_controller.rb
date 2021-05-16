class GuidesController < ApplicationController
  before_action :authenticate_user!,
                only: %i[new create edit update destroy view purchase owned]
  before_action :set_guide, only: %i[show edit update destroy view purchase success cancel]
  skip_before_action :verify_authenticity_token, only: [:purchase]

  # GET /guides
  def index
    # Retrieve all guides for display
    @guides = Guide.all
  end

  # GET /guides/:id
  # Show the details of a guide (but not the file containing guide contents)
  def show; end

  # GET/guides/:id/view
  # View the content of a guide
  def view
    # Get number of pages in guide file for display. Makes a Cloudinary API call.
    @page_count = @guide.get_page_count
  end

  # GET /guides/new
  def new
    # Create an empty guide object to extract attributes for new guide form
    @guide = Guide.new
  end

  # POST /guides
  def create
    # Create a new guide using strong params from form data, assigned to current user
    @guide = current_user.guides.new(guide_params)

    # Redirect and notify success, or re-render "new" page with error messages if creation fails
    if @guide.save
      redirect_to @guide,
                  notice: "Guide \"#{@guide.title}\" was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /guides/:id/edit
  def edit; end

  # PUT/PATCH /guides/:id
  def update
    # Update a guide using strong params from form data.
    # # Redirect and notify if successful, or re-render "edit" page with error messages if update fails.
    if @guide.update(guide_params)
      redirect_to @guide,
                  notice: "Guide \"#{@guide.title}\" was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /guides/:id
  def destroy
    # Delete guide and redirect to index with success notice
    @guide.destroy
    redirect_to guides_url, notice: 'Guide was successfully destroyed.'
  end

  # POST /guides/:id/purchase
  def purchase
    # Prevent initiating purchase if guide already owned
    if @guide.owned_by?(current_user)
      redirect_to @guide, alert: "Unable to purchase: you already own this guide."
    # Otherwise, create Stripe session and render checkout
    else
      Stripe.api_key = ENV['STRIPE_API_KEY']
      session = Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: 'aud',
            product_data: {
              name: @guide.title,
            },
            unit_amount: 500,
          },
          quantity: 1,
        }],
        mode: 'payment',
        # These routes handle successful or canceled checkout
        success_url: "#{request.base_url}/guides/#{@guide.id}/purchase-success?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: "#{request.base_url}/guides/#{@guide.id}/purchase-cancel",
      })
      render json: session
    end
  end

  # GET /guides/:id/purchase-success
  # Called when Stripe checkout succeeds
  def success
    # Add purchased guide to owned guides, unless already present
    current_user.owned_guides.push(@guide) unless @guide.owned_by?(current_user)
    redirect_to @guide, notice: "Thank you for your purchase!"
  end

  # GET /guides/:id/purchase-cancel
  # Called when Stripe checkout canceled
  def cancel
    redirect_to @guide, alert: "Transaction canceled."
  end

  # GET /guides/owned
  # Display all guides owned (purchased) by the current user
  def owned
    @guides = current_user.owned_guides
  end

  private

  # Retrieve a guide based on id restful parameter
  def set_guide
    @guide = Guide.find(params[:id])
  end

  # Get guide attributes from params hash with strong parameters
  def guide_params
    params.require(:guide).permit(:title, :description, :price, :guide_file)
  end
end
