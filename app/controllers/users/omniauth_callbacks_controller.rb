class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # user = User.find_for_facebook_oauth(request.env['omniauth.auth'])

    # if user.persisted?
    #   sign_in_and_redirect user, event: :authentication
    #   set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
    # else
    #   session['devise.facebook_data'] = request.env['omniauth.auth']
    #   redirect_to new_user_registration_url
    # end

    # We already have a current_user  (we're just updating fields)
    current_user.update_with_facebook(request.env['omniauth.auth'])
    flash[:notice] = "Succesfully authenticated from facebook"
    redirect_to edit_user_path(current_user)
  end
end
