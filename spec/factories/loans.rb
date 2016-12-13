FactoryGirl.define do
  factory :loan do |loan|
    loan.association :user
    loan.association :bank
    loan.requested_amount { 1000.00 } # Hard-coded for calculations
    loan.category { ["Personal", "Business"].sample }
    loan.purpose { ["Medical Expenses", "New Equipment", "Transportation"].sample }
    loan.description { "This is a generic string which is long enough" }


    # Creates a loan with all payments paid on time
    trait :outstanding_good_book do
      status { "Loan Outstanding" }
      proposed_amount { requested_amount }
      agreed_amount { requested_amount }
      start_date { DateTime.now - 2.month }
      final_date { start_date + 3.month }
      loan.after(:create) do |loan|
        loan.update_payments_to_agreed_amount
        # This code doesn't carry across to specs for some reason!
        # loan.payments.each do |p|
        #   p.update!(paid: true) if p.due_date < DateTime.now
        # end
      end
    end

    # Creates a loan with a missed payment
    trait :outstanding_missed_payment do
      status { "Loan Outstanding" }
      proposed_amount { requested_amount }
      agreed_amount { requested_amount }
      start_date { DateTime.now - 1.month }
      final_date { start_date + 3.month }
      loan.after(:create) do |loan|
        loan.update_payments_to_agreed_amount
      end
    end

    # Creates a loan with a delayed payment
    trait :outstanding_delayed_payment do
      status { "Loan Outstanding" }
      proposed_amount { requested_amount }
      agreed_amount { requested_amount }
      start_date { DateTime.now - 3.day }
      final_date { start_date + 3.month }
      loan.after(:create) do |loan|
        loan.update_payments_to_agreed_amount
      end
    end
  end
end
