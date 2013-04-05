class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :name
      t.integer :width
      t.integer :height
      t.integer :photo_category_id
      t.integer :main_storage_id
      t.integer :thumb_storage_id
      t.string  :anchor

      t.timestamps
    end
  end
end
