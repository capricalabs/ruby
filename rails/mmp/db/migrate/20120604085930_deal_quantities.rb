class DealQuantities < ActiveRecord::Migration
	def up
		create_table :deal_quantities do |t|
			t.integer :deal_id
			t.integer :qty
			t.decimal :price_change, :precision => 16, :scale => 2
			t.timestamps
		end
		add_index :deal_quantities, :deal_id
	end
	
	def down
		drop_table :deal_quantities
	end
end
