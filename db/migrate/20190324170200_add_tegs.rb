class AddTegs < ActiveRecord::Migration[5.2]
  def self.up
    add_column :marks, :tags, :string
  end
  def self.down
    remove_column :marks, :tags
  end
end
