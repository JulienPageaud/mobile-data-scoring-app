class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :omniauthable, omniauth_providers: [:facebook],
         authentication_keys: [:mobile_number]
  has_many :loans, dependent: :destroy
  has_many :notifications, dependent: :destroy

  geocoded_by :city
  after_validation :geocode, if: :city_changed?

  phony_normalize :mobile_number, default_country_code: 'ZA'
  validates :mobile_number, presence: true, uniqueness: true

  [:title, :first_name, :last_name, :address, :city, :postcode, :employment, :date_of_birth].each do |meth|
    validates meth, presence: true, on: :update, unless: :updating_password?
  end

  validates :email, presence: { message: 'Email can only be edited - not deleted' },
            if: -> {email_was.present?},
            on: :update
  validate :photo_id, :id_present?,
            on: :update, unless: :updating_password?

  def updating_password?
    @password_confirmation.present?
  end

  def email_required?
    false
  end

  mount_uploader :photo_id, PhotoUploader
  def self.find_for_facebook_oauth(auth)
    user_params = auth.to_h.slice(:provider, :uid)
    user_params.merge! auth.info.slice(:email, :first_name, :last_name)
    user_params[:token] = auth.credentials.token
    user_params[:token_expiry] = Time.at(auth.credentials.expires_at)

    user = User.where(provider: auth.provider, uid: auth.uid).first
    user ||= User.where(email: auth.info.email).first # User did a regular sign up in the past.
    if user
      user.update(user_params)
    else
      user = User.new(user_params)
      user.password = Devise.friendly_token[0,20]  # Fake password for validation
      user.save
    end

    return user
  end

  def full_name
    (first_name + ' ' + last_name).titleize
  end

  def update_with_facebook(auth)
    user_params = auth.to_h.slice(:provider, :uid)
    user_params.merge! auth.info.slice(:email, :first_name, :last_name)
    # :user_birthday, :user_location, :gender, :age_range, :user_education_history, :user_relationship',
    # user_params[:facebook_picture_url] = auth.info.image
    user_params[:token] = auth.credentials.token
    user_params[:token_expiry] = Time.at(auth.credentials.expires_at)
    self.update(user_params)
    return user_params
  end

  def check_facial_recognition
    Indico.api_key = ENV['INDICO_API_KEY']
    if photo_id.file.present?
      result = Indico.facial_localization(photo_id.file.file, {sensitivity: 0.4})
      if result.blaUnk?
        errors.add(:photo_id, :no_face_recognised, message: "Face recognition failed. Please upload a valid photo ID")
      end
    end
  end

  private

  def id_present?
    if photo_id.present? || photo_id.metadata.present?
      check_facial_recognition if photo_id_changed?
      return
    end
  end
end
