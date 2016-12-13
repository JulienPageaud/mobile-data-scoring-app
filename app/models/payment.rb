class Payment < ApplicationRecord
  belongs_to :loan
  monetize :amount_cents

  validates :amount, presence: true
  validates :due_date, presence: true

  def missed_payment?
    if due_date < DateTime.now && paid == false
      true
    else
      false
    end
  end
end
