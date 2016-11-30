class RegistrationsController < Devise::RegistrationsController

  def create
    build_resource(sign_up_params)

    if resource.save
      redirect_to after_sign_up_path_for(resource)
    else
      redirect_to root_path(sign_up: true)
    end
  end

  protected

  # Redirect to personal details page
  def after_sign_up_path_for(resource)
    edit_user_path(resource)
  end
end
