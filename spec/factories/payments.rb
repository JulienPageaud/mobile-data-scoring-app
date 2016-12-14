FactoryGirl.define do
  factory :payment do |p|
    p.loan_id { FactoryGirl.build(:loan).id }
    p.amount { rand(100..1000) }
    p.due_date { DateTime.now.end_of_day }

    trait :missed_payment do
      due_date { DateTime.now - 1.month }
    end
  end
end
