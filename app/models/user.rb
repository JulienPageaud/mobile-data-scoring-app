class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable,
         authentication_keys: [:mobile_number]
  has_many :loans

  def email_required?
    false
  end

  def email_changed?
    false
  end

end
