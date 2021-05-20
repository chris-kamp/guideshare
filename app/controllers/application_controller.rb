class ApplicationController < ActionController::Base
  include Pundit

  # Configure permitted parameters for devise controllers
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Permit username and shopping cart params on user signup and on editing user registration
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, cart_attributes: [:user_id]])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, cart_attributes: [:id, :user_id]])
  end
end
