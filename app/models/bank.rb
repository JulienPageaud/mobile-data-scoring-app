class Bank < ApplicationRecord
  has_many :loans
  has_many :bank_users
end
