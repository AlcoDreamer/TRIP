class CreateGeo < ActiveRecord::Migration[5.2]
  def self.up
    add_column :marks, :lat, :string
    add_column :marks, :lng, :string
  end
  def self.down
    remove_column :marks, :lat
    remove_column :marks, :lng
  end
end
