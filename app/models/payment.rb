class Payment < ApplicationRecord
  belongs_to :loan
  monetize :amount_cents

  def missed_payment?
    if due_date < DateTime.now && paid == false
      true
    else
      false
    end
  end
end
