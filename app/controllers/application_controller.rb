class ApplicationController < ActionController::Base
  include Pundit

  # Make user_or_guest method available to views as a helper
  helper_method :user_or_guest
  # Configure permitted parameters for devise controllers
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Permit username and shopping cart params on user signup and on editing user registration
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, cart_attributes: [:user_id]])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, cart_attributes: [:id, :user_id]])
  end

  # Return the current user if logged in. Otherwise, returns an empty User
  # instance for use as a "null object" which will respond to User model methods.
  # Avoids the need to explicitly check if user is nil before calling model methods.
  def user_or_guest
    return user_signed_in? ? current_user : User.new(cart: Cart.new)
  end
end
