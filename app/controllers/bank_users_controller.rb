class BankUsersController < ApplicationController

  # Authentication is on bank_user not user in this case
  skip_before_filter :authenticate_user!

  def index
  end

  def show
  end

  def edit
  end

  def update
  end
end
