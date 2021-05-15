class GuidesController < ApplicationController
  before_action :authenticate_user!,
                only: %i[new create edit update destroy view]
  before_action :set_guide, only: %i[show edit update destroy view]

  def index
    # Retrieve all guides for display
    @guides = Guide.all
  end

  def show; end

  def view; end

  def new
    # Create an empty guide object to extract attributes for new guide form
    @guide = Guide.new
  end

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

  def edit; end

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

  def destroy
    # Delete guide and redirect to index with success notice
    @guide.destroy
    redirect_to guides_url, notice: 'Guide was successfully destroyed.'
  end

  private

  # Retrieve a guide based on id restful parameter
  def set_guide
    @guide = Guide.find(params[:id])
  end

  # Get guide attributes from params hash with strong parameters
  def guide_params
    params.require(:guide).permit(:title, :description, :guide_file)
  end
end
