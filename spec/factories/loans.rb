FactoryGirl.define do
  factory :loan do |loan|
    loan.association :user
    loan.association :bank
    loan.requested_amount { rand(100..15000).round(-2) }
    loan.category { ["Personal", "Business"].sample }
    loan.purpose { ["Medical Expenses", "New Equipment", "Transportation"].sample }
    loan.description { "This is a generic string which is long enough" }
  end
end
