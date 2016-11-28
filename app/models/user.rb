class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :omniauthable, omniauth_providers: [:facebook],
         authentication_keys: [:mobile_number]
  has_many :loans

  validates :email, presence: true, on: :update,
              format: { with: /\A[^@\s]+@([^@.\s]+\.)*[^@.\s]+\z/  }
  validates :title, presence: true, on: :update
  validates :first_name, presence: true, on: :update
  validates :last_name, presence: true, on: :update
  validates :address, presence: true, on: :update
  validates :city, presence: true, on: :update
  validates :postcode, presence: true, on: :update
  validates :employment, presence: true, on: :update
  validates :date_of_birth, presence: true, on: :update

  def email_required?
    false
  end

  def email_changed?
    false
  end

  mount_uploader :photo_id, PhotoUploader
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
    # :user_birthday, :user_location, :gender, :age_range, :user_education_history, :user_relationship',
    # user_params[:facebook_picture_url] = auth.info.image
    user_params[:token] = auth.credentials.token
    user_params[:token_expiry] = Time.at(auth.credentials.expires_at)
    self.update(user_params)
  end
end
