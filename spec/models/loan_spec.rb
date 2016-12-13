require 'rails_helper'

describe Loan do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:loan)).to be_valid
  end

  it "belongs to a user" do
    expect(Loan.reflect_on_association(:user).macro).to eql(:belongs_to)
  end

  it "belongs to a bank" do
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

  context "outstanding loan" do
    subject { FactoryGirl.create(:loan, :outstanding_good_book) }

    describe '#next_payment' do
      it "returns the next due payment" do
        expect(subject).to respond_to(:next_payment)
        expect(subject.next_payment.class).to eql(Payment)
        expect(subject.next_payment.due_date).to be > DateTime.now
      end
    end

    describe '#most_recent_payment' do
      it "returns the payment which was most recently due" do
        expect(subject).to respond_to(:most_recent_payment)
        expect(subject.most_recent_payment.class).to eql(Payment)
        expect(subject.most_recent_payment.due_date).to be < DateTime.now
      end
    end

    describe '#amount_owed' do
      it "calculates the sum of unpaid payments" do
        subject.payments.each do |p|
          p.update(paid: true) if p.due_date < DateTime.now
        end
        expect(subject).to respond_to(:amount_owed)
        expect(subject.amount_owed.class).to eql(Money)
        expect(subject.amount_owed).to eql(766.66.to_money) # HARDCODED
      end
    end

    describe '#remaining_capital' do
      it "calculates the remaining capital" do
        subject.payments.each do |p|
          p.update(paid: true) if p.due_date < DateTime.now
        end
        expect(subject).to respond_to(:remaining_capital)
        expect(subject.remaining_capital.class).to eql(Money)
        expect(subject.remaining_capital).to eql(616.67.to_money) # HARDCODED
      end
    end

    describe '#total_capital_repaid' do
      it "calculates the total repaid capital"
    end
  end


  describe '#loan_classification' do
    it "returns the string 'Good Book' if no missed/delayed payments"

    it "returns the string 'Missed Payment' if a payment has been missed"

    it "returns the string 'Delayed Payment' if a payment is overdue by less than 7 days"
  end

  describe '#accept' do
    it "updates the loan status to Outstanding Loan and updates payments"
  end
end
