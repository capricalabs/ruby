class BankInfo < ActiveRecord::Migration
	def up
		add_column :users, :bank_name, :string
		add_column :users, :account_name, :string
		add_column :users, :account_number, :string
		add_column :users, :swift_code, :string
	end
	
	def down
		remove_column :users, :bank_name
		remove_column :users, :account_name
		remove_column :users, :account_number
		remove_column :users, :swift_code
	end
end
