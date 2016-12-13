FactoryGirl.define do
  factory :payment do |p|
    p.association :loans
  end
end
