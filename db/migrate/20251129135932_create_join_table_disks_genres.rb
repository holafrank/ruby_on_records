class CreateJoinTableDisksGenres < ActiveRecord::Migration[8.1]
  def change
    create_join_table :disks, :genres do |t|
      # t.index [:disk_id, :genre_id]
      # t.index [:genre_id, :disk_id]
    end
  end
end
