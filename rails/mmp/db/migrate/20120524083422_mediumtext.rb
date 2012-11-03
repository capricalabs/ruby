class Mediumtext < ActiveRecord::Migration
	def up
		change_column :products, :features, :text, :limit => 1.megabyte
		change_column :products, :warranty, :text, :limit => 1.megabyte
		change_column :pages, :body, :text, :limit => 1.megabyte
	end
	
	def down
		change_column :products, :features, :text
		change_column :products, :warranty, :text
		change_column :pages, :body, :text
	end
end
