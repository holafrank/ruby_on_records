class AddUserAndClientToSales < ActiveRecord::Migration[8.1]
  def change
    add_reference :sales, :user, null: false, foreign_key: true
    add_reference :sales, :client, null: false, foreign_key: true
  end
end
