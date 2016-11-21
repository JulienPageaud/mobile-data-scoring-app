class AddAmountToPayments < ActiveRecord::Migration[5.0]
  def change
    add_monetize :payments, :amount, currency: { present: false }
  end
end
