class GuidesController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_guide, only: %i[show edit update destroy]
  def index
    @guides = Guide.all
  end

  def show; end

  def new
    @guide = Guide.new
  end

  def create
    # Create a new guide using strong params from form data, then assign it to the current user
    @guide = Guide.new(guide_params)
    @guide.user = current_user
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
    @guide.destroy
    redirect_to guides_url, notice: "Guide was successfully destroyed."
  end

  private

  def set_guide
    @guide = Guide.find(params[:id])
  end

  def guide_params
    params.require(:guide).permit(:title, :description)
  end
end
