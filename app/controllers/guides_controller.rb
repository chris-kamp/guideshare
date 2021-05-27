class GuidesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show checkout]
  before_action :set_guide,
                only: %i[show edit update destroy view archive restore]

  # GET /guides
  def index
    # Retrieve all Tags, used in checkboxes in search form partial
    @tags = Tag.all

    # Retrieve only guides which are "kept" (ie. have not been archived using the Discard gem) and not created by
    # the current user. Eager load user, tags and guide_tags associations, to avoid unnecessary "N+1" queries in the view.
    # Use ".includes" if possible, but use ".preload" instead if filtering for guides that match all selected tags (because
    # .includes causes a grouping error if used with the queries in the "Guide.has_all_tags" scope)
    @guides =
      if params[:search].present? && params[:search][:tags_match].to_i == 1
        Guide.kept.not_published_by(current_user).preload(%i[user tags guide_tags])
      else
        Guide.kept.not_published_by(current_user).includes(%i[user tags guide_tags])
      end

    # If no search params are present, return and render the view. Code below executes only if search params are present.
    return unless params[:search].present?

    # Store the searchbar query
    @query = params[:search][:query]

    # Store array of tag IDs selected for filtering results. First remove empty strings (first element will be an
    # empty string due to Rails query params parsing behaviour) and cast to integers.
    @tag_ids = (params[:search][:tags] - ['']).map(&:to_i)

    # Store the selection for tag filtering (whether to match any or all)
    @tags_match = (params[:search][:tags_match]).to_i

    # Filter guides based on search query, selected tags, and filter type
    @guides = apply_search_filter(@guides, @query, @tag_ids, @tags_match)
  end

  # GET /guides/dashboard
  def dashboard
    # Retrieve all guides of which the current user is the author, using "published_by" custom model scope.
    # Use "includes" to eager load user, guide_tags and tags associations whose attributes are used in the view,
    # to avoid unnecessary "N+1" queries.
    @guides =
      Guide.includes(:user, :guide_tags, :tags).published_by(current_user)
  end

  # GET /guides/:id
  # Displays the listing for a guide (but not the contents of the PDF file attached to the guide)
  def show
    # If user not authorised, redirect to guides index page and alert error.
    authorize_guide(
      @guide,
      'Guide does not exist or you are not authorised to view it',
      guides_path,
    )

    # Use Review model's custom "recent" scope to retrieve the most recently-created 3 reviews
    # of the relevant guide. Use "includes" to eager-load the user to which the review belongs, used
    # in the view to display the author's name.
    @reviews = @guide.reviews.includes(:user).recent(3)
  end

  # GET/guides/:id/view
  # Display the content of the PDF file attached to a Guide
  def view
    # Check if user is authorized to view the guide. If not, redirect with an alert message.
    authorize_guide(@guide, 'You must purchase this guide in order to view it')
    # Retrieve the user who created the guide, used to display the author's name in the view
    @author = @guide.user
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
    # Construct a new guide belonging to the current user using strong params from form data
    @guide = current_user.guides.new(guide_params)

    # Attempt to save the new guide.
    if @guide.save
      # If successful, redirect to the guide's show page and notify success.
      redirect_to @guide,
                  notice: "Guide \"#{@guide.title}\" was successfully created."
    else
      # If save fails, re-render the "new guide" form. Errors will be displayed to the user in the view.
      render :new, status: :unprocessable_entity
    end
  end

  # GET /guides/:id/edit
  def edit
    # If user is not authorised to edit the guide, redirect to the guide's show page and alert the error
    authorize_guide(@guide, 'Only the author may edit this guide')
  end

  # PUT/PATCH /guides/:id
  def update
    # If user is not authorised to update the guide, redirect to the guide's show page and alert the error.
    # To prevent multiple redirect/render error, return if authorisation fails.
    return unless authorize_guide(@guide, 'Only the author may edit this guide')

    # Attempt to update the guide using strong params from form data.
    if @guide.update(guide_params)
      # Redirect to the guides' show page and notify if update successful
      redirect_to @guide,
                  notice: "Guide \"#{@guide.title}\" was successfully updated."
    else
      # Re-render "edit" page with error messages if update fails.
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /guides/:id
  def destroy
    # If user is not authorised to delete the guide, redirect to the guide's show page and alert the error.
    # To prevent multiple redirect/render error, return if authorisation fails.
    return unless authorize_guide(@guide, 'Only the author may delete this guide')

    # If any users have already purchased the guide, redirect to the Guides index page and notify user
    # that the guide cannot be deleted, only archived.
    if @guide.has_owners?
      redirect_to guides_path,
                  alert:
                    'Guide could not be deleted because it has been purchased by one or more users. Try archiving it instead.'
    # Otherwise, allow guide to be deleted, redirect to Guides index and notify success.
    else
      @guide.destroy
      redirect_to guides_path, notice: 'Guide listing was successfully deleted.'
    end
  end

  # GET /guides/:id/archive
  def archive
    # If user is not authorised to archive the guide, redirect to the guide's show page and alert the error.
    # To prevent multiple redirect/render error, return if authorisation fails.
    return unless authorize_guide(@guide, 'Only the author may archive this guide')

    # Archive guide by "soft deleting" using the Discard gem, making it accessible only to the owner and
    # users who have already purchased it.
    @guide.discard

    # Dependents are not destroyed when discarding, so manually remove discarded guides from all users' shopping carts
    CartGuide.for_guide(@guide).destroy_all
    redirect_to guide_path(@guide),
                notice:
                  'Guide listing was successfully archived. NOTE: Any users who already purchased the guide will retain access to it.'
  end

  # GET /guides/:id/restore
  def restore
    unless authorize_guide(
             @guide,
             'Guide does not exist or you are not authorised to restore it from the archive',
           )
      return
    end

    # Restore archived guide by "undiscarding" with Discard gem method, making it accessible to all users again
    @guide.undiscard
    redirect_to guide_path(@guide),
                notice: 'Guide listing was successfully restored.'
  end

  # POST /guides/checkout
  def checkout
    # Retrieve guide ids from params. If received as JSON (such as from Stripe checkout button),
    # first parse array of guide ids from JSON and map each id to an integer.
    @guide_ids =
      if params[:guide_ids].is_a?(String)
        JSON.parse(params[:guide_ids]).map(&:to_i)
      else
        params[:guide_ids]
      end

    # Retrieve guides whose ids are included in the array of guide_ids received via params
    @guides = Guide.where(id: @guide_ids)

    # Prevent initiating purchase if any guide is already owned by the user, or is archived
    return if @guides.any? { |guide| guide.owned_by?(current_user) || guide.discarded? }

    # "Free" param will be true only if the user is attempting to add a single free guide to their library. If so,
    # add the guide to the user's library directly, redirect to the user's library with a success notice, and return.
    if params[:free]
      add_to_library(@guides)
      redirect_to owned_guides_path, notice: 'Guide was added to your library!'
      return
    end

    # If not acquiring a free guide, initiate Stripe checkout.
    # Set API key to access Stripe API
    Stripe.api_key = ENV['STRIPE_API_KEY']

    # Generates an array of line items in Stripe's required format
    @line_items = generate_line_items(@guides)

    # Create a Stripe session
    session =
      Stripe::Checkout::Session.create(
        {
          payment_method_types: ['card'],
          line_items: @line_items,
          mode: 'payment',
          # These routes handle successful or canceled checkout
          success_url:
            "#{request.base_url}/guides/checkout-success?session_id={CHECKOUT_SESSION_ID}",
          cancel_url: "#{request.base_url}/guides/checkout-cancel",
        },
      )

    # Send Stripe session data as JSON
    render json: session
  end

  # GET /guides/checkout-success
  # User is redirected here when Stripe checkout succeeds
  def success
    # Set key to access Stripe API
    Stripe.api_key = ENV['STRIPE_API_KEY']

    # Stripe API call to retrieve information about line items included in purchase
    @line_items_data =
      Stripe::Checkout::Session.list_line_items(params[:session_id])['data']

    # Extract guide IDs from Stripe session data (sent when clicking purchase/checkout button) and map them to @guide_ids
    @guide_ids =
      @line_items_data.map do |item|
        Stripe::Product.retrieve(item['price']['product'])['metadata']['id']
      end

    # Retrieve only those guides whose ids are included in the line items data
    @guides = Guide.where(id: @guide_ids)

    # Adds each purchased guide to the user's owned guides
    add_to_library(@guides)
    redirect_to owned_guides_path, notice: 'Thank you for your purchase!'
  end

  # GET /guides/checkout-cancel
  # User is redirected here when Stripe checkout is canceled
  def cancel
    redirect_to guides_path, notice: 'Purchase canceled.'
  end

  # GET /guides/owned
  # Display all guides owned (purchased) by the current user
  def owned
    # Retrieve only guides owned by the current user. Use "includes" to eager load the user to which
    # the guide belongs and the guide's guide_tags and tags associations, which are used in the view.
    @guides = current_user.owned_guides.includes(:user, :guide_tags, :tags)
  end

  private

  # Retrieve a guide based on ID obtained from RESTful parameters
  def set_guide
    @guide = Guide.find(params[:id])
  end

  # Use strong params to extract attributes used for Guide creation from params
  def guide_params
    params.require(:guide).permit(:title, :description, :price, :guide_file)
  end

  # Pundit method to set the "user" in guide_policy
  def pundit_user
    # Defined in application_controller. Returns an empty User object if user is not logged in.
    user_or_guest
  end

  # Check if user authorised to access a given guide.
  # If not, redirect to a given path (default: show page for the guide) with a given alert message.
  def authorize_guide(guide, alert_msg, redir = guide_path(guide))
    begin
      authorize guide
    rescue NotAuthorizedError
      redirect_to redir, alert: alert_msg

      # Return false if error occurred, to allow a conditional check when calling method
      return false
    end

    # Return true if no error occurred
    return true
  end

  # Add each of a given array of guides to the current user's library, unless already owned
  def add_to_library(guides)
    guides.each do |guide|
      # Add the guide to the user's owned guides
      current_user.owned_guides.push(guide) unless guide.owned_by?(current_user)
      # Then, if guide is in the user's shopping cart, remove it
      remove_from_cart(guide)
    end
  end

  # Remove a guide from the current user's shopping cart
  def remove_from_cart(guide)
    # Return if the guide is not in the user's cart
    return unless current_user.cart.guides.exists?(guide.id)

    # If guide is in the user's cart, delete the relevant CartGuide instance
    current_user.cart.cart_guides.find_by(guide_id: guide.id).destroy
  end

  # Given an array of guides, generate line item hashes for each in Stripe's required format
  def generate_line_items(guides)
    return(
      guides.map do |guide|
        {
          price_data: {
            currency: 'aud',
            product_data: {
              name: guide.title,
              metadata: {
                id: guide.id,
              },
            },
            # Price (in cents) is 100 times the guide's "price" (stored in dollars as a decimal), converted to integer
            unit_amount: (guide.price * 100).to_i,
          },
          quantity: 1,
        }
      end
    )
  end

  # Apply search filters to a collection of guides, and return the filtered collection
  def apply_search_filter(guides, query, tag_ids, tag_match_type)
    filtered_guides = guides
    # If a search query is "present" (non-empty and not only whitespace), filter for guides matching the query
    # using the title_matches_query custom Guide scope
    filtered_guides = filtered_guides.title_matches_query(query) if query.present?

    # If any tag_ids are present in search parameters, filter for guides matching any or all of them
    # (depending on whether "any" or "all" was selected in search form) using custom Guide scopes
    if tag_ids.present?
      filtered_guides =
        # tag_match_type value of 0 corresponds to "Any" - in this case, filter for guides with any selected tag
        if tag_match_type.zero?
          filtered_guides.has_any_tag(tag_ids)
        # Otherwise, filter for guides matching all selected tags
        else
          filtered_guides.has_all_tags(tag_ids)
        end
    end
    return filtered_guides
  end

end
