class CreatePhotoCategories < ActiveRecord::Migration
  def change
    create_table :photo_categories do |t|
      t.string :name
      t.integer :photo_category_id

      t.timestamps
    end
  end
end
