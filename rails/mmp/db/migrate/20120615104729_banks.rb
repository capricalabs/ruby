class Banks < ActiveRecord::Migration
	def up
		create_table :banks do |t|
			t.string :city, :null => true
			t.string :state, :null => true
			t.string :country
			t.text :bank_info
			t.timestamps
		end
	end
	
	def down
		drop_table :banks
	end
end
