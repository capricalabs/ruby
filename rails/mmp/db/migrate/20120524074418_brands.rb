class Brands < ActiveRecord::Migration
	def up
		create_table :brands do |t|
			t.string :name
			t.boolean :active, :default => false
			t.timestamps
		end
	end
	
	def down
		drop_table :brands
	end
end
