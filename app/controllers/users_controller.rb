class UsersController < ApplicationController

  # Authentication is on user not bank_user in this case
  skip_before_filter :authenticate_bank_user!

  before_action :set_user, only: [:show, :edit, :update]
  before_action :set_user_id, only: [:status, :profile, :share]

  def show
    authorize @user
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    if params[:user][:title] == "mr"
      @user.update(gender: "male")
    else
      @user.update(gender: "female")
    end

    if @user.update(user_params)
      redirect_to user_path(@user)
    else
      redirect_to edit_user_path(@user), notice: "Sorry, something went wrong"
    end
  end

  def status
    authorize @user
  end

  def profile
    authorize @user
  end

  def share
    authorize @user
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def set_user_id
    @user = User.find(params[:user_id])
  end

  def user_params
    params.require(:user).permit(:mobile_number, :title, :email, :first_name, :last_name,
      :address, :city, :postcode, :employment, :date_of_birth, :photo_id)
  end
end
