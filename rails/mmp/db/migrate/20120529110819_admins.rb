class Admins < ActiveRecord::Migration
	def up
		create_table :admins do |t|
			t.string :email
			t.string :password
			t.boolean :active, :default => true
			t.string :name
			t.timestamps
		end
	end
	
	def down
		drop_table :admins
	end
end
