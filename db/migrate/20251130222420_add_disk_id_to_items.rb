class AddDiskIdToItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :items, :disk, null: false, foreign_key: true
  end
end
