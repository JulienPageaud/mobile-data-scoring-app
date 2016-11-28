class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :omniauthable, omniauth_providers: [:facebook],
         authentication_keys: [:mobile_number]
  has_many :loans
  has_many :notifications, dependent: :destroy

  def email_required?
    false
  end

  def email_changed?
    false
  end

  # def self.find_for_facebook_oauth(auth)
  #   user_params = auth.to_h.slice(:provider, :uid)
  #   user_params.merge! auth.info.slice(:email, :first_name, :last_name)
  #   user_params[:token] = auth.credentials.token
  #   user_params[:token_expiry] = Time.at(auth.credentials.expires_at)

  #   user = User.where(provider: auth.provider, uid: auth.uid).first
  #   user ||= User.where(email: auth.info.email).first # User did a regular sign up in the past.
  #   if user
  #     user.update(user_params)
  #   else
  #     user = User.new(user_params)
  #     user.password = Devise.friendly_token[0,20]  # Fake password for validation
  #     user.save
  #   end

  #   return user
  # end

  def update_with_facebook(auth)
    user_params = auth.to_h.slice(:provider, :uid)
    user_params.merge! auth.info.slice(:email, :first_name, :last_name)
    # user_params[:facebook_picture_url] = auth.info.image
    user_params[:token] = auth.credentials.token
    user_params[:token_expiry] = Time.at(auth.credentials.expires_at)
    self.update(user_params)
  end

  def confirm_loan
    body = "Thank you for confirming your loan\
            (amount: #{ActionController::Base.helpers.humanized_money_with_symbol(loans.last.agreed_amount)}).
            Your e-wallet will be credited shortly!
            Your next payment:
            #{ActionController::Base.helpers.humanized_money_with_symbol(loans.last.next_payment.amount)} on #{loans.last.next_payment.due_date.strftime("%e %b %Y")}"
    Notification.send_sms(mobile_number, body.squish)
  end

  def decline_loan
    body = "You have chosen to decline your loan.
            We hope you will consider reapplying in the future"
    Notification.send_sms(mobile_number, body.squish)
  end
end
