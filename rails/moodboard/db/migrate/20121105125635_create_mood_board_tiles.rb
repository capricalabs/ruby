class CreateMoodBoardTiles < ActiveRecord::Migration
  def change
    create_table :mood_board_tiles do |t|
      t.integer :mood_board_id
      t.integer :photo_id
      t.integer :storage_id

      t.integer :x
      t.integer :y
      t.integer :width
      t.integer :height

      t.integer :edit_width
      t.integer :edit_height
      t.integer :edit_x_offset
      t.integer :edit_y_offset

      t.timestamps
    end
  end
end
