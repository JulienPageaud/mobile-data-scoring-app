class ChangeColumnPaidInPayments < ActiveRecord::Migration[5.0]
  def change
    change_column :payments, :paid, :boolean, default: false
  end
end
