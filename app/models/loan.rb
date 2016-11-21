class Loan < ApplicationRecord
  belongs_to :bank
  belongs_to :user
  monetize :requested_amount_cents
  monetize :proposed_amount_cents
  monetize :agreed_amount_cents
end
