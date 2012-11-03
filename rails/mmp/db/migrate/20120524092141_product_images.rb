class ProductImages < ActiveRecord::Migration
	def up
		create_table :product_images do |t|
			t.integer :product_id
			t.string :image
			t.timestamps
		end
		add_index :product_images, :product_id
	end
	
	def down
		drop_table :product_images
	end
end
