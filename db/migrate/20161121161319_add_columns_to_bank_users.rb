class AddColumnsToBankUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :bank_users, :first_name, :string
    add_column :bank_users, :last_name, :string
    add_column :bank_users, :phone_number, :string
    add_reference :bank_users, :bank, foreign_key: true
  end
end
