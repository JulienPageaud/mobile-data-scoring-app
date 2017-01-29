class Payment < ApplicationRecord
  belongs_to :loan
  monetize :amount_cents

  validates :amount, presence: true
  validates :due_date, presence: true

  def missed_payment?
    if (due_date < DateTime.now.end_of_day - 7.day) && paid == false
      true
    else
      false
    end
  end

  def delayed_payment?
    if (due_date < DateTime.now.end_of_day) && (due_date > DateTime.now.end_of_day - 7.day) && paid == false
      true
    else
      false
    end
  end
end
