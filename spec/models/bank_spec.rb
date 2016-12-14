require 'rails_helper'

RSpec.describe Bank, type: :model do
  subject { FactoryGirl.build(:bank) }

  it "has a name" do
    subject.name = nil
    expect(subject).to_not be_nil
  end

  it "has a unique name" do
    bank1 = subject
    bank1.save
    bank2 = subject.dup
    expect(bank2).to_not be_valid
  end

  it "has many loans" do
    expect(Bank.reflect_on_association(:loans).macro).to eql(:has_many)
  end

  it "has many bank users" do
    expect(Bank.reflect_on_association(:bank_users).macro).to eql(:has_many)
  end

  it "has many users (through loans)" do
    expect(Bank.reflect_on_association(:users).macro).to eql (:has_many)
  end

  it "has many payments (through loans)" do
    expect(Bank.reflect_on_association(:payments).macro).to eql (:has_many)
  end
end
