class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_review, only: %i[show edit update destroy]

  def index
  end

  def show
  end

  def new
    # Get guide by id from RESTful params. Use find_by to return false if not found (where find() would raise exception)
    @guide = Guide.find_by(id: params[:guide_id])
    # Redirect with alert unless guide with given ID exists and has been purchased by the current user
    unless @guide && @guide.owned_by?(current_user)
      redirect_to guides_path, alert: "Guide does not exist or cannot be reviewed. You can only review a guide you own and which has not been archived."
    end
    @review = Review.new
    # Set guide id for inclusion in hidden form field
    @review.guide_id = params[:guide_id]
  end

  def create
    @review = current_user.reviews.new(review_params)
    if @review.save
      redirect_to @review,
                  notice: "Review was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:content, :rating, :guide_id)
  end
end
