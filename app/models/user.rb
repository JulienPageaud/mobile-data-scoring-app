class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :loans
  validates :mobile_number, uniqueness: true, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true


end
