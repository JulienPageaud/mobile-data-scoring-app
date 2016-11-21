class ChangeEmailAndMobileNumberInUsers < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :email, :string, null: true
    change_column :users, :mobile_number, :string, null: false
  end
end
