class AddSuspendedToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :suspended, :boolean, default: false, null: false
  end
end
