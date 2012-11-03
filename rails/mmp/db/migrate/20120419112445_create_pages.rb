class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.text :body
      t.text :meta_tags

      t.timestamps
    end
  end
end
