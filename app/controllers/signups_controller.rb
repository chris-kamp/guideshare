# Extends devise registrations controller to provide added functionality
class SignupsController < Devise::RegistrationsController
  # Overwrite "new" registration method to build shopping cart for user upon signup
  def new
    build_resource
    resource.build_cart
    yield resource if block_given?
    respond_with resource
  end
end