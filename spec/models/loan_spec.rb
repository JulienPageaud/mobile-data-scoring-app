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

  context 'accepted application' do
    subject { FactoryGirl.create(:loan, :accepted_application) }

    describe '#accept' do
      it "responds to this method" do
        expect(subject).to respond_to(:accept)
      end

      it "updates the loan status to Loan Outstanding and updates payments" do
        subject.accept({
          agreed_amount: subject.proposed_amount,
          start_date: subject.start_date,
          final_date: subject.final_date
        })
        expect(subject.status).to eql("Loan Outstanding")
        expect(subject.payments).to_not be_nil
      end

      it "sets the start and end date" do
        expect(subject.start_date).to_not be_nil
        expect(subject.final_date).to eq(subject.start_date + subject.duration_months.month)
      end

      it "sets the agreed loan amount" do
        expect(subject.agreed_amount).to_not be_nil
        expect(subject.agreed_amount).to be <= subject.proposed_amount
      end
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
      it "returns nil if the loan has been repaid" do
        subject.payments.each do |p|
          p.update(paid: true)
        end
        expect(subject.amount_owed).to eq(0.to_money)
      end

      it "calculates the sum of unpaid payments" do
        subject.payments.each do |p|
          p.update(paid: true) if p.due_date < DateTime.now
        end
        expect(subject).to respond_to(:amount_owed)
        expect(subject.amount_owed.class).to eql(Money)
        expect(subject.amount_owed).to eql(920.to_money) # HARDCODED
      end
    end

    describe '#amount_overdue' do
      it "returns total amount of overdue payments"
    end

    describe '#remaining_capital' do
      it "returns 0 if the capital has been repaid in full" do
        subject.payments.each do |p|
          p.update(paid: true)
        end
        expect(subject.remaining_capital).to eq(0.to_money)
      end

      it "calculates the remaining capital" do
        subject.payments.each do |p|
          p.update(paid: true) if p.due_date < DateTime.now
        end
        expect(subject).to respond_to(:remaining_capital)
        expect(subject.remaining_capital.class).to eql(Money)
        expect(subject.remaining_capital).to eql(920.to_money) # HARDCODED
      end
    end

    describe '#total_capital_repaid' do#
      it "returns 0 if no payments have been repaid yet" do
        expect(subject.total_capital_repaid).to eq(0.to_money)
      end

      it "calculates the total repaid capital" do
        subject.payments.each do |p|
          p.update(paid: true) if p.due_date < DateTime.now
        end
        expect(subject).to respond_to(:total_capital_repaid)
        expect(subject.total_capital_repaid.class).to eql(Money)
        expect(subject.total_capital_repaid).to eql(460.to_money)
      end
    end

    describe '#total_capital' do
      it "returns the total amount to be repaid" do
        expect(subject).to respond_to(:total_capital)
        expect(subject.total_capital.class).to eql(Money)
        expect(subject.total_capital).to eql(1380.to_money)
      end
    end

    describe '#loan_classification' do
      let(:delayed_payment) { FactoryGirl.create(:loan, :outstanding_delayed_payment) }
      let(:missed_payment) { FactoryGirl.create(:loan, :outstanding_missed_payment) }
      it "responds to this method" do
        expect(subject).to respond_to(:loan_classification)
      end

      it "returns the string 'Good Book' if no missed/delayed payments" do
        subject.payments.each { |p| p.update(paid: true) if p.due_date < DateTime.now }
        expect(subject.loan_classification).to eql('Good Book')
      end

      it "returns the string 'Missed Payment' if a payment has been missed" do
        expect(missed_payment.loan_classification).to eql('Missed Payment')
      end

      it "returns the string 'Delayed Payment' if a payment is overdue by less than 7 days" do
        expect(delayed_payment.loan_classification).to eql('Delayed Payment')
      end
    end
  end
end
