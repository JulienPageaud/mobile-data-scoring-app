class UsersController < ApplicationController

  # Authentication is on user not bank_user in this case
  skip_before_action :authenticate_bank_user!

  before_action :set_user_and_latest_loan, only: [:show, :profile]
  before_action :set_user, only: [:edit, :update, :status, :share]

  def show
    authorize @user
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    # Checks if user email has been changed
    @user.email = params[:user][:email]
    send_email = @user.email_changed?
    if @user.update(user_params)
      UserMailer.email_has_changed(@user).deliver_later if send_email
      @user.check_facial_recognition_and_mark_complete
      if @user.details_completed
        redirect_to user_path(@user)
      else
        flash[:alert] = "Your photo failed face recognition. Please upload a valid photo ID"
        render :edit
      end
    else
      render :edit
    end
  end

  def status
    authorize @user
    @user.notifications.each { |n| n.update(read: true)} if @user.notifications.present?
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

  def set_user_and_latest_loan
    @user = User.find(params[:id])
    @latest_loan = @user.loans.last
  end

  def user_params
    params.require(:user).permit(:mobile_number, :title, :email, :first_name, :last_name,
      :address, :city, :postcode, :employment, :date_of_birth, :photo_id, :photo_id_cache)
  end
end
