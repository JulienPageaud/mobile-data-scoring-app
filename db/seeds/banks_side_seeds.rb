Loan.destroy_all
User.destroy_all
Bank.create!(name: "FNB") unless Bank.find_by_name("FNB").present?
BankUser.create!(email: "fnbemployee@gmail.com", password: "ilovemoney",
  first_name: "Mr.", last_name: "Banks", phone_number: '999-785-$$$',
  bank: Bank.find_by_name("FNB")) unless BankUser.find_by_email("fnbemployee@gmail.com").present?
User.create!(mobile_number: 1234560, password: 123456, first_name: "Tom", last_name: "Cruise", )

cities_ary = ["Johannesburg", 'Cape Town', 'Durban', 'Pretoria', 'Port Elizabeth', 'Bloemfontein', 'East London']

status_ary = ["Application Pending", "Application Accepted", "Loan Outstanding", "Application Declined", "Loan Repaid"]
category_ary = ["Personal", "Business"]
purpose_ary = ["Medical Expenses", "Start a business", "Open a shop", "Coding School", "Beer Money"]
description_ary = ["I need to pay for a organ transplant for my son",
  "I want to buy a large amount of cooking utensils for my kitchen as the restaurant is expanding",
  "I would like to open a clothes shop as there are none in this area",
  "I want to start my own tech business and I need the money to launch my product",
  "I want to learn how to code Ruby on Rails applications at Le Wagon",
  "I'm really thirsty so I want to buy lots of beer"]
decline_reason_ary = ["Credit score too low",
  "Insufficient mobile data", "Criminal record"]

start_date_outstanding_ary = [(DateTime.now - 3.day), (DateTime.now - 1.month),
  (DateTime.now - 2.month), (DateTime.now - 15.day),
  (DateTime.now - 8.day - 1.month)]
start_date_repaid_ary = [(DateTime.now - 1.month), (DateTime.now - 2.month),
  (DateTime.now - 3.month), (DateTime.now - 20.day),
  (DateTime.now -3.day)]

bank = Bank.find_by_name("FNB")

# Pending Applications
30.times do
  mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(20) + 80).fdiv(100).round(2))

  loan = user.loans.build(category: category_ary.sample,
    status: "Application Pending", purpose: purpose_ary.sample,
    description: description_ary.sample, interest_rate: 15,
    bank: bank, requested_amount: rand(100..15000).round(-2))
  loan.save!
end

# Accepted Application
15.times do
  mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(10) + 90).fdiv(100).round(2))

  loan = user.loans.build(category: category_ary.sample,
    status: "Application Accepted", purpose: purpose_ary.sample,
    description: description_ary.sample, interest_rate: 15,
    bank: bank, requested_amount: rand(100..15000).round(-2))
  loan.update!(proposed_amount: loan.requested_amount)
  loan.create_payments_proposed
end

# Good Book Loans
30.times do
  mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(10) + 90).fdiv(100).round(2))

  loan = user.loans.build(category: category_ary.sample,
    status: "Loan Outstanding", purpose: purpose_ary.sample,
    description: description_ary.sample, interest_rate: 15,
    bank: bank, requested_amount: rand(100..15000).round(-2))
  loan.update!(proposed_amount: loan.requested_amount, agreed_amount: loan.requested_amount,
    start_date: DateTime.now - (rand(1..50).round.day))
  loan.update!(final_date: (loan.start_date + loan.duration_months.month))
  loan.update_payments_to_agreed_amount
  loan.payments.each do |payment|
    payment.update!(paid: true) if payment.due_date < DateTime.now
  end
end

# Missed Payment Loans
3.times do
    mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(10) + 80).fdiv(100).round(2))

  loan = user.loans.build(category: category_ary.sample,
    status: "Loan Outstanding", purpose: purpose_ary.sample,
    description: description_ary.sample, interest_rate: 15,
    bank: bank, requested_amount: rand(100..15000).round(-2))
  loan.update!(proposed_amount: loan.requested_amount, agreed_amount: loan.requested_amount,
    start_date: DateTime.now - (rand(1..2).month + (rand(8..50).round.day)))
  loan.update!(final_date: (loan.start_date + loan.duration_months.month))
  loan.update_payments_to_agreed_amount
  loan.payments.each do |payment|
    payment.update!(paid: true) if payment.due_date < DateTime.now
  end
  loan.most_recent_payment.update!(paid:false)
end

# Delayed Payment Loans
2.times do
  mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(10) + 80).fdiv(100).round(2))

  loan = user.loans.build(category: category_ary.sample,
    status: "Loan Outstanding", purpose: purpose_ary.sample,
    description: description_ary.sample, interest_rate: 15,
    bank: bank, requested_amount: rand(100..15000).round(-2))
  loan.update!(proposed_amount: loan.requested_amount, agreed_amount: loan.requested_amount,
    start_date: DateTime.now - (1.month + (rand(1..7).round.day)))
  loan.update!(final_date: (loan.start_date + loan.duration_months.month))
  loan.update_payments_to_agreed_amount
  loan.payments.each do |payment|
    payment.update!(paid: true) if payment.due_date < DateTime.now
  end
  loan.most_recent_payment.update(paid:false)
end

# Repaid Payment Loans
10.times do
  mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(5) + 92).fdiv(100).round(2))

  loan = user.loans.build(category: category_ary.sample,
    status: "Loan Repaid", purpose: purpose_ary.sample,
    description: description_ary.sample, interest_rate: 15,
    bank: bank, requested_amount: rand(100..15000).round(-2))
  loan.update!(proposed_amount: loan.requested_amount, agreed_amount: loan.requested_amount,
    start_date: DateTime.now - (rand(1..50).round.day))
  loan.update!(final_date: (loan.start_date + loan.duration_months.month))
  loan.update_payments_to_agreed_amount
  loan.payments.each do |payment|
    payment.update!(paid: true)
  end
end


# Declined Payment Loans
10.times do
  mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(10) + 80).fdiv(100).round(2))

  loan = user.loans.build(category: category_ary.sample,
    status: "Application Declined", purpose: purpose_ary.sample,
    description: description_ary.sample, interest_rate: 15,
    bank: bank, requested_amount: rand(100..15000).round(-2),
    decline_reason: decline_reason_ary.sample)
  loan.update!(created_at: DateTime.now - rand(3..10).day, final_date: DateTime.now - rand(0..2).day)
end
