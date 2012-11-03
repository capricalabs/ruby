class Products < ActiveRecord::Migration
	def up
		create_table :products do |t|
			t.integer :brand_id
			t.string :name
			t.boolean :active, :default => false
			t.string :model
			t.text :summary
			t.text :features
			t.text :warranty
			t.timestamps
		end
		add_index :products, :brand_id
	end
	
	def down
		drop_table :products
	end
end
