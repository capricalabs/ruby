class CustomerRepId < ActiveRecord::Migration
	def up
		add_column :users, :admin_id, :integer
		add_index :users, :admin_id
		add_column :admins, :phone, :string
	end

	def down
		remove_column :users, :admin_id
		remove_column :admins, :phone
	end
end
