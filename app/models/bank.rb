class Bank < ApplicationRecord
  has_many :loans
  has_many :users, through: :loans
  has_many :payments, through: :loans
  has_many :bank_users

  def net_balance_sheet
    balance = 0
    loans.where(status: "Loan Outstanding").each do |loan|
      balance += loan.remaining_capital
    end
    loans.where(status: "Application Accepted").each do |loan|
      balance -= loan.proposed_amount
    end
    return balance
  end

  def pending_response
    loans.where(status: "Application Pending").count
  end

  def pending_repayment
    loans.where(status: "Loan Outstanding").count
  end

  def total_users_count
    users.count
  end

  # Returns all the customers with pending loan applications
  def pending_customers
    users.joins(:loans).where("loans.status" => "Application Pending")
  end

  # Returns all the customers with live loans
  def live_customers
    users.joins(:loans).where("loans.status" => ["Application Accepted", "Loan Outstanding"])
  end

  def customers_count
    users.joins(:loans).where("loans.status" => ["Application Accepted", "Loan Outstanding"]).count
  end

  def average_score_of_pending_customers
    total_credit_score = 0
    users.joins(:loans).where("loans.status" => "Application Pending").each do |user|
      total_credit_score += user.credit_score.to_f
    end

    total_credit_score / users.joins(:loans).where("loans.status" => "Application Pending").count
  end

  def average_score_of_active_customers
    total_score = 0
      users.joins(:loans).where("loans.status" => ["Application Accepted", "Loan Outstanding"]).each do |user|
        total_score += user.credit_score.to_f
      end

    total_score / customers_count
  end

  #Returns an array with frequency of customer in credit score brackets (75, 80, 85... etc.)
  def credit_score_distribution_pending
    seventy = 0
    seventy_five = 0
    eighty = 0
    eighty_five = 0
    ninety = 0
    ninety_five = 0
    pending_customers.each do |customer|
      if customer.credit_score.to_f > 0.95
        ninety_five += 1
      elsif customer.credit_score.to_f > 0.90
        ninety += 1
      elsif customer.credit_score.to_f > 0.85
        eighty_five += 1
      elsif customer.credit_score.to_f > 0.80
        eighty += 1
      elsif customer.credit_score.to_f > 0.75
        seventy_five += 1
      elsif customer.credit_score.to_f > 0.70
        seventy +=1
      end
    end
    return [seventy, seventy_five, eighty, eighty_five, ninety, ninety_five]
  end

  def credit_score_distribution_live
    seventy = 0
    seventy_five = 0
    eighty = 0
    eighty_five = 0
    ninety = 0
    ninety_five = 0
    live_customers.each do |customer|
      if customer.credit_score.to_f > 0.95
        ninety_five += 1
      elsif customer.credit_score.to_f > 0.90
        ninety += 1
      elsif customer.credit_score.to_f > 0.85
        eighty_five += 1
      elsif customer.credit_score.to_f > 0.80
        eighty += 1
      elsif customer.credit_score.to_f > 0.75
        seventy_five += 1
      elsif customer.credit_score.to_f > 0.70
        seventy +=1
      end
    end
    return [seventy, seventy_five, eighty, eighty_five, ninety, ninety_five]
  end

  def applications_accepted
    loans.where(status: ["Application Accepted", "Loan Outstanding"]).where(updated_at: DateTime.now - 7.day..DateTime.now).count
  end

  def applications_declined
    loans.where(status: "Application Declined").where(updated_at: DateTime.now - 7.day..DateTime.now).count
  end
end
