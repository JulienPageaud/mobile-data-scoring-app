require 'rails_helper'

RSpec.describe Bank, type: :model do
  subject { FactoryGirl.create(:bank) }

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

  describe '#net_balance_sheet' do
    it 'returns an amount' do
      expect(subject).to respond_to(:net_balance_sheet)
      expect(subject.net_balance_sheet.class).to eql(Money)
    end
  end

  describe '#pending_response' do
    it 'returns the number of pending applications' do
      expect(subject).to respond_to(:pending_response)
      expect(subject.pending_response.class).to eql(Fixnum)
    end
  end

  describe '#pending_repayment' do
    it 'returns the number of outstanding loans' do
      expect(subject).to respond_to(:pending_repayment)
      expect(subject.pending_repayment.class).to eql(Fixnum)
    end
  end

  describe '#total_users_count' do
    it 'returns the total number of users' do
      expect(subject).to respond_to(:total_users_count)
      expect(subject.total_users_count.class).to eql(Fixnum)
    end
  end

  describe '#pending_customers' do
    it 'returns all customers with pending loan applications' do
      user = FactoryGirl.create(:user)
      loan = FactoryGirl.build(:loan, user: user, bank_id: subject.id, status: "Application Pending")
      loan.save
      expect(subject).to respond_to(:pending_customers)
      expect(subject.pending_customers.first.class).to eql(User)
    end
  end

  describe '#live_customers' do
    it 'returns all customers with live loans' do
      user = FactoryGirl.create(:user)
      loan = FactoryGirl.build(:loan, user: user, bank: subject, status: "Loan Outstanding")
      loan.save
      expect(subject).to respond_to(:live_customers)
      expect(subject.live_customers.first.class).to eql(User)
    end
  end

  describe '#customers_count' do
    it 'returns the total number of customers' do
      user = FactoryGirl.create(:user)
      loan = FactoryGirl.build(:loan, user: user, bank: subject, status: "Loan Outstanding")
      loan.save
      expect(subject).to respond_to(:customers_count)
      expect(subject.customers_count.class).to eql(Fixnum)
    end
  end

  describe '#average_score_of_pending_customers' do
    it 'returns the average credit score of customers with pending applications' do
      user = FactoryGirl.create(:user)
      loan = FactoryGirl.build(:loan, user: user, bank: subject, status: "Application Pending")
      loan.save
      expect(subject).to respond_to(:average_score_of_pending_customers)
      expect(subject.average_score_of_pending_customers.class).to eql(Float)
    end
  end

  describe '#average_score_of_active_customers' do
    it 'returns the average credit score of customers with live loans' do
      user = FactoryGirl.create(:user)
      loan = FactoryGirl.build(:loan, user: user, bank: subject, status: "Loan Outstanding")
      loan.save
      expect(subject).to respond_to(:average_score_of_active_customers)
      expect(subject.average_score_of_active_customers.class).to eql(Float)
    end
  end

  describe '#credit_score_distribution_pending' do
    it 'returns an array with frequency of pending customers in credit score brackets' do
      expect(subject).to respond_to(:credit_score_distribution_pending)
      expect(subject.credit_score_distribution_pending.class).to eql(Array)
    end
  end

  describe '#credit_score_distribution_live' do
    it 'returns an array with frequency of live customers in credit score brackets' do
      expect(subject).to respond_to(:credit_score_distribution_live)
      expect(subject.credit_score_distribution_live.class).to eql(Array)
    end
  end

  describe '#applications_accepted' do
    it 'returns the number of applications accepted this week' do
      user = FactoryGirl.create(:user)
      loan = FactoryGirl.build(:loan, user: user, bank: subject, status: "Loan Outstanding")
      expect(subject).to respond_to(:applications_accepted)
      expect(subject.applications_accepted.class).to eql(Fixnum)
    end
  end

  describe '#applications_declined' do
    it 'returns the number of applications declined this week' do
      user = FactoryGirl.create(:user)
      loan = FactoryGirl.build(:loan, user: user, bank: subject, status: "Application Declined")
      expect(subject).to respond_to(:applications_declined)
      expect(subject.applications_declined.class).to eql(Fixnum)
    end
  end

end
