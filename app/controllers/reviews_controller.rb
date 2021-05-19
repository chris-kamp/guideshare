class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_review, only: %i[show edit update destroy]
  before_action :set_guide, only: %i[new create]

  def index
  end

  # GET /guides/:guide_id/reviews/new
  def new
    @review = Review.new
    # Set guide id for authorisation and inclusion in hidden form field
    @review.guide_id = params[:guide_id]
    # Redirect with alert unless guide with given ID exists and has been purchased by the current user
    return false unless authorize_review(@review, "Guide does not exist or you are not authorised to review it. You can only review a guide you own.", guides_path)
  end

  # POST /guides/:guide_id/reviews
  def create
    @review = current_user.reviews.new(review_params)
    return false unless authorize_review(@review, "Guide does not exist or you are not authorised to review it. You can only review a guide you own.", guides_path)
    if @review.save
      redirect_to @guide,
                  notice: "Review was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /reviews/:id/edit
  def edit
    authorize_review(@review, "Only the author may edit this review")
  end

  # PUT/PATCH /reviews/:id
  def update
    # To prevent multiple redirect/render error, return if authorisation fails.
    return unless authorize_review(@review, "Only the author may edit this review")

    # Attempt to update a guide using strong params from form data.
    if @review.update(review_params)
      # Redirect and notify if update successful
      redirect_to @review.guide,
                  notice: "Review was successfully updated."
    else
      # Re-render "edit" page with error messages if update fails.
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def set_review
    @review = Review.find(params[:id])
  end

  def set_guide
    @guide = Guide.find(params[:guide_id])
  end

  def review_params
    params.require(:review).permit(:content, :rating, :guide_id)
  end

  # Check if user authorised to access a given review.
  # If not, redirect to given path (default: guide show page) with given alert message.
  def authorize_review(review, alert_msg, redir=guide_path(review.guide))
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
