class ChangeBooleanColumnNamesInUsers < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :details_completed?, :details_completed
    rename_column :users, :facebook_account?, :facebook_account
  end
end
