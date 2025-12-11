class CreateDisks < ActiveRecord::Migration[8.1]
  def change
    create_table :disks do |t|
      t.string :title, null: false
      t.string :artist, null: false
      t.integer :year, null: false
      t.text :description, null: false
      t.float :price, null: false
      t.integer :stock, default: 0, null: false
      t.string :format, null: false
      t.string :state, null: false

      t.timestamps
    end
  end
end
