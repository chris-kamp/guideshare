class GuidesController < ApplicationController
  before_action :authenticate_user!,
                only: %i[new create edit update destroy view purchase owned success cancel dashboard archive restore]
  before_action :set_guide, only: %i[show edit update destroy view purchase success cancel archive restore]
  skip_before_action :verify_authenticity_token, only: [:purchase]

  # GET /guides
  def index
    # Retrieve tags for use in checkboxes
    @tags = Tag.all
    # Retrieve guides for display. Use "kept" (from discard gem) to retrieve only those that have not been soft deleted.
    @guides = Guide.kept

    if params["search"].present?
      # Get search query from search params
      @query = params["search"]["query"]
      # Get tag IDs from search params, and remove any empty string elements
      # (first element is always an empty string due to Rails behaviour)
      @tag_ids = (params["search"]["tags"] - [""]).map(&:to_i)
      @tags_match = (params["search"]["tags_match"]).to_i
    end
    # If search query is "present" (non-empty and not only whitespace), filter
    # for guides with titles matching the query (using a case-insensitive wildcard search)
    if @query.present?
      @guides = @guides.where("title ILIKE ?", "%#{@query}%")
    end
    # If tag ids are present, filter for guides whose tags include them
    if @tag_ids.present? 
      # Match any tags if "Any" selected
      if @tags_match == 0
        @guides = @guides.select { |guide| @tag_ids.any?{ |tag_id| guide.tag_ids.include?(tag_id) } }
      # Otherwise, match all tags
      else
        @guides = @guides.select { |guide| @tag_ids.all?{ |tag_id| guide.tag_ids.include?(tag_id) } } 
      end
    end
  end

  # GET /guides/dashboard
  def dashboard
    # Retrieve all guides of which the current user is the author
    @guides = current_user.guides
  end

  # GET /guides/:id
  # Shows a guide listing (but not file content)
  def show
    # If user not authorised, redirect to show page and alert error.
    authorize_guide(@guide, "Guide does not exist or you are not authorised to view it", guides_path)
    # Select the most recent 3 reviews to display
    @reviews = @guide.reviews.order(created_at: :desc).limit(3)
  end

  # GET/guides/:id/view
  # View the content of a guide file
  def view
    authorize_guide(@guide, "You must purchase this guide in order to view it")
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
  def edit
    authorize_guide(@guide, "Only the author may edit this guide")
  end

  # PUT/PATCH /guides/:id
  def update
    # To prevent multiple redirect/render error, return if authorisation fails.
    return unless authorize_guide(@guide, "Only the author may edit this guide")

    # Attempt to update a guide using strong params from form data.
    if @guide.update(guide_params)
      # Redirect and notify if update successful
      redirect_to @guide,
                  notice: "Guide \"#{@guide.title}\" was successfully updated."
    else
      # Re-render "edit" page with error messages if update fails.
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /guides/:id
  def destroy
    return unless authorize_guide(@guide, "Only the author may delete this guide")

    # Allow guide to be deleted only if no users have purchased it.
    if !@guide.has_owners?
      @guide.destroy
      redirect_to guides_url, notice: 'Guide listing was successfully deleted.'
    else
      redirect_to guides_url, alert: 'Guide could not be deleted because it has been purchased by one or more users. Try archiving it instead.'
    end
  end

  # GET /guides/:id/archive
  def archive
    return unless authorize_guide(@guide, "Only the author may archive this guide")

    # Archive guide by "soft deleting" using "discard" gem. 
    # Only the author and users who have already purchased the guide will be able to access it.
    @guide.discard
    redirect_to guides_url, notice: 'Guide listing was successfully archived. NOTE: Any users who already purchased the guide will retain access to it.'
  end

  # GET /guides/:id/restore
  def restore
    return unless authorize_guide(@guide, "Guide does not exist or you are not authorised to restore it from the archive")

    # Restore archived guide, making it accessible to users who don't already own it
    @guide.undiscard
    redirect_to guide_url(@guide), notice: 'Guide listing was successfully restored.'
  end

  # POST /guides/:id/purchase
  def purchase

    # Prevent initiating purchase if guide already owned or is discarded
    if @guide.owned_by?(current_user) || @guide.discarded?
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

  # Check if user authorised to access a given guide.
  # If not, redirect to given path (default: show page) with given alert message.
  def authorize_guide(guide, alert_msg, redir=guide_path(guide))
    begin
      authorize guide
    rescue NotAuthorizedError
      redirect_to redir, alert: alert_msg
      # Return false if error occurred to allow conditional check when calling method
      return false
    end
    # Return true if no error occurred
    return true
  end
end
