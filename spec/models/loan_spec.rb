require 'rails_helper'

describe Loan do
  it "belongs to a user" do
    expect(Loan.reflect_on_association(:user).macro).to eql(:belongs_to)
  end

  it "belong to a bank" do
    expect(Loan.reflect_on_association(:bank).macro).to eql(:belongs_to)
  end

  it "has many payments" do
    expect(Loan.reflect_on_association(:payments).macro).to eql(:has_many)
  end

  context "new application" do
    subject { FactoryGirl.build(:loan) }

    it "has a requested amount" do
      subject.requested_amount = nil
      expect(subject).not_to be_valid
    end

    it "has a category" do
      subject.category = nil
      expect(subject).not_to be_valid
    end

    it "has a purpose" do
      subject.purpose = nil
      expect(subject).not_to be_valid
    end

    it "has a description" do
      subject.description = nil
      expect(subject).not_to be_valid
    end

    it "has a description of at least 20 characters" do
      subject.description = "Not long"
      expect(subject).not_to be_valid
    end

    it "has a user" do
      subject.user = nil
      expect(subject).not_to be_valid
    end

    it "has a bank" do
      subject.bank = nil
      expect(subject).not_to be_valid
    end
  end

  describe '#next_payment' do
    it "returns the next due payment"
  end

  describe '#most_recent_payment' do
    it "returns the payment which was most recently due"
  end

  describe '#amount_owed' do
    it "calculates the sum of unpaid payments"
  end

  describe '#remaining_capital' do
    it "calculates the remaining capital"
  end

  describe '#total_capital_repaid' do
    it "calculates the total repaid capital"
  end

  describe '#loan_classification' do
    it "returns loan classification string (Missed Payment, Delayed Payment or Good Book)"
  end

  describe '#accept' do
    it "updates the loan status to Outstanding Loan and updates payments"
  end
end
