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

  ## PAYMENT METHODS

  # Retrieve the next payment which is due
  def next_payment
    payments.where('due_date > ?', DateTime.now).first
  end

  # Retrieve the most recent payment which has passed it's due date
  def most_recent_payment
    payments.where('due_date < ?', DateTime.now).last
  end

  # Calculate the amount owed (sum of unpaid payments)
  def amount_owed
    amount = 0
    payments.where('due_date < ?', DateTime.now).where(paid: false).each do |payment|
      amount += payment.amount
    end
    return amount
  end

  # Calculate the remaining capital on the loan
  def remaining_capital
    payments_total = 0
    payments.each do |payment|
      payments_total += payment.amount if payment.paid == true
    end
    return agreed_amount - payments_total
  end

  # Calculate the total repaid capital
  def total_capital_repaid
    sum = Money.new(0)
    payments.each do |payment|
      sum += payment.amount if payment.paid == true
    end
    sum.currency.to_s + ' ' + sum.to_s
  end

  ## LOAN FILTERS

  # Finds loans which have no missed/delayed payments
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

  # Finds loans which have missed payments (due_date + 7 days)
  def self.missed_payment_loans
    where(status: "Loan Outstanding").joins(:payments).where('payments.due_date < ?', (DateTime.now - 7.day)).where(payments: { paid: false })
  end

  # Finds loans which have delayed payments (less than 7 days since due date)
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


  ## MONEY DISPLAYING METHODS
  # display the agreed capital with currency + amount
  def display_capital
    agreed_amount.currency.to_s + ' ' + agreed_amount.to_s
  end

  # display the proposed capital with currency + amount
  def display_proposed_capital
    proposed_amount.currency.to_s + ' ' + proposed_amount.to_s
  end

  # display the requested capital with currency + amount
  def display_requested_capital
    requested_amount.currency.to_s + ' ' + requested_amount.to_s
  end


end
