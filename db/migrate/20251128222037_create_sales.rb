class CreateSales < ActiveRecord::Migration[8.1]
  def change
    create_table :sales do |t|
      t.boolean :cancelled, default: false, null: false
      t.float :total, null: false

      t.timestamps
    end
  end
end
