class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :authenticate_bank_user!

  include Pundit

  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  private

  def skip_pundit?
    devise_controller? || controller_name == "pages"
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      user_path(resource)
    elsif resource.is_a?(BankUser)
      bank_user_loans_path(resource)
    end
  end
end
