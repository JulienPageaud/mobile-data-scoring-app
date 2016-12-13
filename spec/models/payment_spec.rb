require 'rails_helper'

RSpec.describe Payment, type: :model do
  subject { FactoryGirl.create(:payment) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  it 'has an amount (which is a Money object)' do
    subject.amount = nil
    expect(subject.amount).not_to be_nil
    expect(subject.amount.class).to eql(Money)
  end

  it 'has a due date' do
    subject.due_date = nil
    expect(subject).not_to be_valid
  end

  describe '#missed_payment?' do
    subject { FactoryGirl.create(:payment, :missed_payment)}

    it 'returns true if payment is unpaid and passed its d ue date' do
      expect(subject).to respond_to(:missed_payment?)
      expect(subject.missed_payment?).to eql(true)
    end
  end
end
