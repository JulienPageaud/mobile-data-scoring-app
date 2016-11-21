class Payment < ApplicationRecord
  belongs_to :loan
  monetize :amount_cents
end
