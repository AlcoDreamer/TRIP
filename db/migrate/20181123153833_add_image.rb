class AddImage < ActiveRecord::Migration[5.2]
  def self.up
    add_column :marks, :image, :string
  end
  def self.down
    remove_column :marks, :image
  end
end
