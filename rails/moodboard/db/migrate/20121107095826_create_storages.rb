class CreateStorages < ActiveRecord::Migration
  def change
    create_table :storages do |t|
      t.string :randkey
      t.string :prefix
      t.string :ext

      t.timestamps
    end
  end
end
