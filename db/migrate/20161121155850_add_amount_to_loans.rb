class AddAmountToLoans < ActiveRecord::Migration[5.0]
  def change
    add_monetize :loans, :requested_amount, currency: { present: false }
    add_monetize :loans, :proposed_amount, currency: { present: false }
    add_monetize :loans, :agreed_amount, currency: { present: false }
  end
end
