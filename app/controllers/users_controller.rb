class UsersController < ApplicationController

  # Authentication is on user not bank_user in this case
  skip_before_filter :authenticate_bank_user!

  before_action :set_user, only: [:show, :edit, :update, :status]

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user)
    else
      redirect_to edit_user_path(@user), notice: "Sorry, something went wrong"
    end
  end

  def status
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:mobile_number, :gender, :first_name, :last_name,
      :address, :city, :postcode, :employment, :date_of_birth, :photo_id)
  end
end
