class GuidesController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_guide, only: %i[show edit update destroy]
  def index; end

  def show; end

  def new
    @guide = Guide.new
  end

  def create
    if @guide.save
      redirect_to @guide, notice: "Guide \"#{@guide.title}\" was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update; end

  def destroy; end

  private

  def set_guide
    @guide = Guide.find(params[:id])
  end
end
