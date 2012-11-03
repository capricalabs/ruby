class Users < ActiveRecord::Migration
	def up
		create_table :users do |t|
			t.string :email
			t.string :password
			t.boolean :dealer
			t.string :name
			t.string :company
			t.string :phone
			t.timestamps
		end
	end
	
	def down
		drop_table :users
	end
end
