class UsersController < ApplicationController

  # Authentication is on user not bank_user in this case
  skip_before_filter :authenticate_bank_user!

  def show
  end

  def edit
  end

  def update
  end
end
