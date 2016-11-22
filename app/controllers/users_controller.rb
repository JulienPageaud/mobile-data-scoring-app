class UsersController < ApplicationController

  # Authentication is on user not bank_user in this case
  skip_before_filter :authenticate_bank_user!

  before_action :show, :edit, :update

  def show
  end

  def edit
    if current_user.id == @user.id
      return
    else
      redirect_to root_path
    end
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user)
    else
      redirect_to edit_user_path(@user), notice: "Sorry, something went wrong"
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

end
