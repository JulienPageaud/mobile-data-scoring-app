class BankUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         authentication_keys: [:email]

  belongs_to :bank
  has_many :loans, through: :bank

  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    (first_name + ' ' + last_name).titleize
  end
end
