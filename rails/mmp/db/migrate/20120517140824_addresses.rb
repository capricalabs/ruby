class Addresses < ActiveRecord::Migration
	def up
		create_table :addresses do |t|
			t.integer :user_id
			t.boolean :billing
			t.boolean :default
			t.string :line
			t.string :line2
			t.string :city
			t.string :state
			t.string :zip
			t.string :country
			t.timestamps
		end
		add_index :addresses, :user_id
	end

	def down
		drop_table :addresses
	end
end
