class AddParams < ActiveRecord::Migration[5.2]
  def self.up
    add_column :marks, :title, :string
    add_column :marks, :author, :string
    add_column :marks, :description, :text
  end
  def self.down
    remove_column :marks, :title
    remove_column :marks, :author
    remove_column :marks, :description
  end
end
