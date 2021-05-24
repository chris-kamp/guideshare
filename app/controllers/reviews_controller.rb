class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_review, only: %i[show edit update destroy]
  before_action :set_guide, only: %i[new create index]

  # GET /guides/:guide_id/reviews
  def index
    # Retrieve only those reviews belonging to the relevant guide for display.
    # Use "includes" to eager load the user to which the review belongs (ie. its author) for use in the view.
    @reviews = @guide.reviews.includes(:user)
  end

  # GET /guides/:guide_id/reviews/new
  def new
    # Check if user has already reviewed the guide, using a User model method. If so, redirect with an alert,
    # and return to terminate the action.
    if current_user.reviewed?(@guide)
      redirect_to @guide,
                  alert:
                    'You have already reviewed this guide. You cannot review the same guide more than once.'
      return
    end
    # Instantiate an empty Review object, used to generate form fields
    @review = Review.new
    # Obtain guide ID from RESTful params, and assign to the review. Passed through to Create via a hidden form field.
    @review.guide_id = params[:guide_id]
    # Redirect with alert unless user is authorised to create a review for this guide.
    return unless authorize_review(
             @review,
             'Guide does not exist or you are not authorised to review it. You can only review a guide you own.',
             guides_path,
           )
  end

  # POST /guides/:guide_id/reviews
  def create
    # Check if user has already reviewed the guide, using a User model method. If so, redirect with an alert,
    # and return to terminate the action and prevent multiple renders/redirects error.
    if current_user.reviewed?(@guide)
      redirect_to @guide,
                  alert:
                    'You have already reviewed this guide. You cannot review the same guide more than once.'
      return
    end

    # Instantiate a review belonging to the current user, passing in strong params from form data
    @review = current_user.reviews.new(review_params)

    # Redirect with alert unless user is authorised to create a review for this guide.
    return unless authorize_review(
             @review,
             'Guide does not exist or you are not authorised to review it. You can only review a guide you own.',
             guides_path,
           )
    # If review is able to be saved, redirect to show page for the guide to which it belongs, and notify success
    if @review.save
      redirect_to @guide, notice: 'Review was successfully created.'
    # Otherwise, re-render the New Review form, which will display the errors which prevented saving.
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /reviews/:id/edit
  def edit
    # Redirect and alert if user is not authorised to edit the review
    authorize_review(@review, 'Only the author may edit this review')
  end

  # PUT/PATCH /reviews/:id
  def update
    # Redirect and alert if user is not authorised to edit the review. 
    # To prevent multiple redirect/render error, return if authorisation fails.
    unless authorize_review(@review, 'Only the author may edit this review')
      return
    end

    # Attempt to update the guide using strong params from form data.
    if @review.update(review_params)
      # Redirect and notify success if update successful
      redirect_to @review.guide, notice: 'Review was successfully updated.'
    else
      # Re-render "edit" page with error messages if update fails.
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /reviews/:id
  def destroy
    # Redirect, alert and return if the current user is not authorised to delete the review
    return unless authorize_review(@review, 'Only the author may delete this review')

    # Retrieve the guide to which the review belongs, used in redirect destination after deletion
    @guide = @review.guide
    @review.destroy
    redirect_to @guide, notice: 'Review was successfully deleted.'
  end

  private

  # Retrieve a review based on ID obtained from RESTful parameters
  def set_review
    @review = Review.find(params[:id])
  end

  # Retrieve a guide based on ID obtained from RESTful parameters
  # (noting review routes are shallowly nested under guides)
  def set_guide
    @guide = Guide.find(params[:guide_id])
  end

  # Use strong params to extract attributes used for Review creation from params
  def review_params
    params.require(:review).permit(:content, :rating, :guide_id)
  end

  # Check if user authorised to access a given review.
  # If not, redirect to given path (default: guide show page) with given alert message.
  def authorize_review(review, alert_msg, redir = guide_path(review.guide))
    begin
      authorize review
    rescue NotAuthorizedError
      redirect_to redir, alert: alert_msg

      # Return false if error occurred to allow conditional check when calling method
      return false
    end

    # Return true if no error occurred
    return true
  end
end
