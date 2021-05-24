# Extends Devise registrations controller to modify behaviour
class SignupsController < Devise::RegistrationsController
  # Overwrite Devise "New" registration action to build shopping cart for the user upon signup,
  # which is passed through to Create via a hidden field in the signup form view
  def new
    build_resource
    resource.build_cart
    yield resource if block_given?
    respond_with resource
  end
end
