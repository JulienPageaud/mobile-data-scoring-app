class Loan < ApplicationRecord
  belongs_to :bank, optional: true
  belongs_to :user
  has_many :payments, dependent: :destroy

  monetize :requested_amount_cents
  monetize :proposed_amount_cents
  monetize :agreed_amount_cents

  validates :requested_amount, presence: true,
              numericality: { less_than_or_equal_to: 15000, greater_than: 0 }
  validates :category, presence: true
  validates :purpose, presence: true
  validates :description, presence: true,
              length: { minimum: 20,
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
    agreed_amount - payments_total
  end

  # Calculate the total repaid capital
  def total_capital_repaid
    sum = Money.new(0)
    payments.each do |payment|
      sum += payment.amount if payment.paid == true
    end
    return sum
  end

  ## LOAN FILTERS

  # Finds loans which have no missed/delayed payments
  def self.good_loans
    result = order(start_date: :desc).where(status: "Loan Outstanding").reject { |loan| Loan.missed_payment_loans.include?(loan) }
    result.reject { |loan| Loan.delayed_payment_loans.include?(loan)}
  end

  # Finds loans which have missed payments (due_date + 7 days)
  def self.missed_payment_loans
    order(start_date: :desc).where(status: "Loan Outstanding").joins(:payments).where('payments.due_date < ?', (DateTime.now.end_of_day - 7.day)).where(payments: { paid: false })
  end

  # Finds loans which have delayed payments (less than 7 days since due date)
  def self.delayed_payment_loans
    result = order(start_date: :desc).where(status: "Loan Outstanding").joins(:payments).where(payments: {due_date: DateTime.now.end_of_day - 7.day..DateTime.now.end_of_day}).where(payments: { paid: false })
    result.select { |loan| loan unless missed_payment_loans.include?(loan) }
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

  ## OUTSTANDING LOAN CLASSIFICATION METHODS
  def loan_classification
    if status == "Loan Outstanding" && most_recent_payment.present?
      if Loan.missed_payment_loans.include?(self)
        "Missed Payment"
      elsif Loan.delayed_payment_loans.include?(self)
        "Delayed Payment"
      else
        "Good Book"
      end
    elsif status == "Loan Outstanding"
      "Good Book"
    end
  end

  def accept(arguments)
    update(status: "Loan Outstanding")
    update(arguments)
    update_payments_to_agreed_amount
  end

  def application_sent_confirmation
    # Send SMS confirmation
    body = "Your loan application for
            #{ActionController::Base.helpers.humanized_money_with_symbol(requested_amount)}
            has been sent successfully.
            You will receive another message once it has been reviewed."
    SmsJob.perform_later(user.mobile_number, body.squish)
    #Notification.send_sms(user.mobile_number, body.squish)

    #Send e-mail confirmation
    if user.email.present?
      UserMailer.application_sent_confirmation(user: user, loan: self).deliver_later
    end
  end
end
