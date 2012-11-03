class Deals < ActiveRecord::Migration
	def up
		create_table :deals do |t|
			t.integer :user_id
			t.integer :product_id
			t.integer :qty
			t.decimal :price, :precision => 16, :scale => 2
			t.string :currency, :limit => 3
			t.date :start_date
			t.date :end_date
			t.boolean :active, :default => true
			t.decimal :customs_duty_price, :precision => 16, :scale => 2
			t.decimal :warranty_cost, :precision => 16, :scale => 2
			t.decimal :addon_commission, :precision => 5, :scale => 2
			t.timestamps
		end
		add_index :deals, :user_id
		add_index :deals, :product_id
	end
	
	def down
		drop_table :deals
	end
end
