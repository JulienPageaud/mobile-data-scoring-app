class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable,
         authentication_keys: [:mobile_number]
  has_many :loans

  validates :mobile_number, uniqueness: true, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  def email_required?
    false
  end

  def email_changed?
    false
  end
end
