class GuidesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show checkout]
  before_action :set_guide, only: %i[show edit update destroy view archive restore]
  skip_before_action :verify_authenticity_token, only: [:checkout]

  # GET /guides
  def index
    # Retrieve tags for use in checkboxes
    @tags = Tag.all
    # Retrieve guides for display. Use "kept" (from discard gem) to retrieve only those that have not been archived.
    @guides = Guide.kept
    # If search was used, extract search params
    if params["search"].present?
      @query = params["search"]["query"]
      # Remove empty string elements from tags array -
      # first element in an array of query params is always an empty string due to Rails behaviour
      @tag_ids = (params["search"]["tags"] - [""]).map(&:to_i)
      @tags_match = (params["search"]["tags_match"]).to_i
      @guides = apply_search_filter(@guides, @query, @tag_ids, @tags_match)
    end
  end

  # GET /guides/dashboard
  def dashboard
    # Retrieve all guides of which the current user is the author
    @guides = Guide.published_by(current_user)
  end

  # GET /guides/:id
  # Shows a guide listing (but not file content)
  def show
    # If user not authorised, redirect to show page and alert error.
    authorize_guide(@guide, "Guide does not exist or you are not authorised to view it", guides_path)
    # Select the most recent 3 reviews to display
    @reviews = @guide.reviews.recent(3)
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
    # Dependents are not destroyed when discarding, so manually remove discarded guides from all users' shopping carts
    CartGuide.for_guide(@guide).destroy_all
    redirect_to guides_url, notice: 'Guide listing was successfully archived. NOTE: Any users who already purchased the guide will retain access to it.'
  end

  # GET /guides/:id/restore
  def restore
    return unless authorize_guide(@guide, "Guide does not exist or you are not authorised to restore it from the archive")

    # Restore archived guide, making it accessible to users who don't already own it
    @guide.undiscard
    redirect_to guide_url(@guide), notice: 'Guide listing was successfully restored.'
  end

  # POST /guides/checkout
  def checkout
    # Retrieve guide ids from params. If received as JSON (such as from Stripe checkout button),
    # first parse array of guide ids from JSON and map each id to an integer.
    @guide_ids = params[:guide_ids].is_a?(String) ? JSON.parse(params[:guide_ids]).map(&:to_i) : params[:guide_ids]
    # Select guides whose ids are included in the guide_ids received as params
    @guides = Guide.where(id: @guide_ids)
    # Prevent initiating purchase if any guide is already owned or is archived
    return if @guides.any? { |guide| guide.owned_by?(current_user) || guide.discarded? }
    # Add guide to library directly if params indicate a free guide is being acquired
    if params[:free]
      add_to_library(@guides)
      redirect_to owned_guides_path, notice: "Guide was added to your library!"
      return
    end
    # If not acquiring a free guide, initiate Stripe checkout
    # Set API key to access Stripe API
    Stripe.api_key = ENV['STRIPE_API_KEY']
    # Generate array of line items in Stripe's required format
    @line_items = generate_line_items(@guides)
    # Create Stripe session
    session = Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      line_items: @line_items,
      mode: 'payment',
      # These routes handle successful or canceled checkout
      success_url: "#{request.base_url}/guides/checkout-success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{request.base_url}/guides/checkout-cancel",
    })
    # Send session data as JSON
    render json: session
  end

  # GET /guides/checkout-success
  # Called when Stripe checkout succeeds
  def success
    # Set key to access Stripe API
    Stripe.api_key = ENV['STRIPE_API_KEY']
    # Stripe API call to retrieve information about line items included in purchase
    @line_items_data = Stripe::Checkout::Session.list_line_items(params[:session_id])['data']
    # Extract guide IDs from Stripe session data (set when clicking purchase/checkout button) and map them to @guide_ids
    @guide_ids = @line_items_data.map { |item| Stripe::Product.retrieve(item['price']['product'])['metadata']['id'] }
    # Select only those guides whose ids are included in the line items data
    @guides = Guide.where(id: @guide_ids)
    # Add each purchased guide to owned guides, unless already present
    add_to_library(@guides)
    redirect_to owned_guides_path, notice: "Thank you for your purchase!"
  end

  # GET /guides/checkout-cancel
  # Called when Stripe checkout canceled
  def cancel
    redirect_to guides_path, notice: "Purchase canceled."
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

  # Define "user" for Pundit with user_or_guest method, returning a null object if not logged in
  def pundit_user
    # Defined in application_controller
    user_or_guest
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

  # Add a given array of guides to the current user's library, unless already owned
  def add_to_library(guides)
    guides.each do |guide|
      current_user.owned_guides.push(guide) unless guide.owned_by?(current_user)
      remove_from_cart(guide)
    end
  end

  # Remove a guide from the current user's shopping cart (used to ensure purchased guides do not remain in the cart)
  def remove_from_cart(guide)
    return unless current_user.cart.guides.exists?(guide.id)
    current_user.cart.cart_guides.find_by(guide_id: guide.id).destroy
  end

  # Given an array of guides, generate line items in Stripe's required format
  def generate_line_items(guides)
    return guides.map do |guide|
      {
        price_data: {
          currency: 'aud',
          product_data: {
            name: guide.title,
            metadata: {
              id: guide.id,
            }
          },
          # Price (in cents) is 100 times the guides "price" attribute (stored in dollars as a decimal)
          unit_amount: (guide.price * 100).to_i,
        },
        quantity: 1
      }
    end
  end

  # Apply search filters to a collection of guides, and return the filtered collection
  def apply_search_filter(guides, query, tag_ids, tag_match_type)
    filtered_guides = guides
    # If a search query is "present" (non-empty and not only whitespace), filter for guides matching the query
    filtered_guides = filtered_guides.title_matches_query(query) if query.present?
    # If any tag_ids are present in search parameters, filter for guides matching any or all of them
    # (depending on whether "any" or "all" was selected in search form)
    if tag_ids.present?
      filtered_guides = tag_match_type.zero? ? filtered_guides.has_any_tag(tag_ids) : filtered_guides.has_all_tags(tag_ids)
    end
    return filtered_guides
  end
end
