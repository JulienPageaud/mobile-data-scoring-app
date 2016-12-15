class RegistrationsController < Devise::RegistrationsController

  def create
    build_resource(sign_up_params)

    if resource.save
      redirect_to edit_user_path(resource)
    else
      redirect_to root_path(sign_up: true)
    end

    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
    end
  end

  protected

  # Redirect to personal details page
  def after_sign_up_path_for(resource)
    edit_user_path(resource)
  end

  def after_update_path_for(resource)
    user_path(resource)
  end
end
