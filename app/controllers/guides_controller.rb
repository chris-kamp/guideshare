class GuidesController < ApplicationController
  before_action :authenticate_user!,
                only: %i[new create edit update destroy view purchase owned]
  before_action :set_guide, only: %i[show edit update destroy view purchase]

  def index
    # Retrieve all guides for display
    @guides = Guide.all
  end

  # Show the details of a guide (but not the file containing guide contents)
  def show; end

  # View the content of a guide
  def view
    # Get number of pages in guide file for display
    @page_count = @guide.get_page_count
  end

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

  # Add a guide to the current user's owned guides
  def purchase
    # Notify failure if user already owns the guide. Otherwise, add to owned guides and notify success.
    if @guide.owned_by?(current_user)
      redirect_to @guide, alert: "Purchase failed: you already own this guide."
    else
      current_user.owned_guides.push(@guide)
      redirect_to @guide, notice: "Guide \"#{@guide.title}\" was successfully purchased."
    end
  end

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
    params.require(:guide).permit(:title, :description, :guide_file)
  end
end
