class ChangeTypeToCategoryInLoans < ActiveRecord::Migration[5.0]
  def change
    rename_column :loans, :type, :category
  end
end
