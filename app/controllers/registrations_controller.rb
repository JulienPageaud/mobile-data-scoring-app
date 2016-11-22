class RegistrationsController < Devise::RegistrationsController
  protected

  # Redirect to personal details page
  def after_sign_up_path_for(resource)
    edit_user_path(resource)
  end
end
