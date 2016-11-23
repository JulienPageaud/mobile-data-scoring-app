# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
status_ary = ["Application Pending", "Application Accepted", "Loan Outstanding", "Application Declined", "Loan Repaid"]
category_ary = ["Personal", "Business"]
purpose_ary = ["Medical Expenses", "Start a business", "Open a shop", "Buy equipment for my business"]
description_ary = ["I really need to pay for a kidney transplant for my eldest son who is suffering from a horrible disease",
               "I want to buy a large amount of cooking utensils for my kitchen as the restaurant is expanding",
               "I would like to open a clothes shop as the locals in the area are complaining and there is a good market",
               "I want to start my own business which is a belly dancer marketplace so that you can rent a belly dancer for your bar mitzvah"]
bank = Bank.last
50.times do
  user = User.create!(mobile_number: Faker::PhoneNumber.cell_phone, password: 'testtest')
  loan = user.loans.build(status: status_ary.sample, category: category_ary.sample, purpose: purpose_ary.sample,
                   description: description_ary.sample, interest_rate: 15, bank: bank,
                   requested_amount_cents: rand(1500000).round(-3))
  loan.save!
end


