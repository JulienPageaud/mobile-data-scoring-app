class Loan < ApplicationRecord
  belongs_to :bank, optional: true
  belongs_to :user
  has_many :payments, dependent: :destroy

  monetize :requested_amount_cents
  monetize :proposed_amount_cents
  monetize :agreed_amount_cents

  validates :requested_amount, presence: true
  validates :category, presence: true
  validates :purpose, presence: true
  validates :description, presence: true, length: { minimum: 50,
    too_short: "You need to exceed %{count} characters in your description" }


  def next_payment
    payments.where('due_date > ?', DateTime.now).first
  end

  def self.good_loans
    result = (where(status: "Loan Outstanding").joins(:payments).where("payments.due_date < ?", DateTime.now).where(payments: {paid: true})).to_a
    new_loans = []
    where(status: "Loan Outstanding").each do |loan|
      if loan.payments.present? && loan.payments.first.due_date > DateTime.now
        new_loans << loan
      end
    end
    if result.present?
      return result << new_loans
    else
      return new_loans
    end
  end

  def remaining_capital
    payments_total = 0
    payments.each do |payment|
      payments_total += payment.amount if payment.paid == true
    end
    return agreed_amount - payments_total
  end

  def self.missed_payment_loans
    where(status: "Loan Outstanding").joins(:payments).where('payments.due_date < ?', (DateTime.now - 7.day)).where(payments: { paid: false })
  end

  def self.delayed_payment_loans
    where(status: "Loan Outstanding").joins(:payments).where('payments.due_date < ?',DateTime.now).where(payments: { paid: false })
  end


  # This method is used to create the payments which are shown to the user before confirming/accepting the loan
  def create_payments_proposed
    payment_amount = ((proposed_amount.amount * (1 + interest_rate.fdiv(100))) / duration_months) * 100

    counter = 1
    duration_months.times do
      payment = payments.build(amount_cents: payment_amount, due_date: (DateTime.now.end_of_day + counter.month)) # DateTime.now used as start_date will be set later
      payment.save
      counter += 1
    end
  end

  # This method is used to create the final payments based on the agreed amount which is entered by the user
  # Old payments are destroyed and replaced by new ones based on this new amount
  def update_payments_to_agreed_amount
    payments.destroy_all

    payment_amount = ((agreed_amount.amount * (1 + interest_rate.fdiv(100))) / duration_months) * 100
    counter = 1
    duration_months.times do
      payment = payments.build(amount_cents: payment_amount, due_date: (start_date.end_of_day + counter.month))
      payment.save
      counter += 1
    end
  end

  def display_capital
    agreed_amount.currency.to_s + ' ' + agreed_amount.to_s
  end

  def display_proposed_capital
    proposed_amount.currency.to_s + ' ' + proposed_amount.to_s
  end

  def display_requested_capital
    requested_amount.currency.to_s + ' ' + requested_amount.to_s
  end
end
