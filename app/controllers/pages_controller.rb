class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]
  skip_before_action :authenticate_bank_user!, only: [ :home ]

  def home
    if params[:number]
      @user = User.new(mobile_number: params[:number])
      @user.valid?
    end

    redirect_to user_path(current_user) if current_user
  end

  def about
  end

  def legal
  end

  def contact
  end
end
