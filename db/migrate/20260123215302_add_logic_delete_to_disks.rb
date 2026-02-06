class AddLogicDeleteToDisks < ActiveRecord::Migration[8.1]
  def change
    add_column :disks, :logic_delete, :boolean, default: false, null: false
    add_column :disks, :deleted_at, :datetime
  end
end
