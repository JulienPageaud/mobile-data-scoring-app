FactoryGirl.define do
  factory :loan do |loan|
    loan.association :user
    loan.association :bank
    loan.requested_amount { rand(100..15000).round(-2) }
    loan.category { ["Personal", "Business"].sample }
    loan.purpose { ["Medical Expenses", "New Equipment", "Transportation"].sample }
    loan.description { "This is a generic string which is long enough" }

    trait :outstanding_good_book do
      loan.status { "Loan Outstanding" }
      loan.proposed_amount { loan.requested_amount }
      loan.agreed_amount { loan.requested_amount }
      loan.start_date { DateTime.parse("2016-12-13") }
      loan.final_date { DateTime.parse("2017-02-13") }
    end

    trait :outstanding_missed_payment do

    end

    trait :outstanding_delayed_payment do

    end
  end
end
