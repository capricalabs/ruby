class AddDeviseToAdmins < ActiveRecord::Migration
  def self.up
    change_table(:admins) do |t|
      ## Database authenticatable
#      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      ## Token authenticatable
      # t.string :authentication_token


      # Uncomment below if timestamps were not included in your original model.
      # t.timestamps
    end

    add_index :admins, :email,                :unique => true
    add_index :admins, :reset_password_token, :unique => true
    # add_index :admins, :confirmation_token,   :unique => true
    add_index :admins, :unlock_token,         :unique => true
    # add_index :admins, :authentication_token, :unique => true
    
    remove_column :admins, :password
  end

  def self.down
  	add_column :admin, :password, :string
	remove_column :admins, :encrypted_password
	remove_column :admins, :reset_password_token
	remove_column :admins, :reset_password_sent_at
	remove_column :admins, :remember_created_at
	remove_column :admins, :sign_in_count
	remove_column :admins, :current_sign_in_at
	remove_column :admins, :current_sign_in_ip
	remove_column :admins, :last_sign_in_ip
	remove_column :admins, :failed_attempts
	remove_column :admins, :unlock_token
	remove_column :admins, :locked_at
  end
end
