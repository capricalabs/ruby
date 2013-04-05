class CreateMoodBoards < ActiveRecord::Migration
  def change
    create_table :mood_boards do |t|
      t.string :name
      t.text :desc
      t.string :status

      t.integer :width
      t.integer :height

      t.string :main_storage_id
      t.string :thumb_storage_id

      t.timestamps
    end
  end
end
