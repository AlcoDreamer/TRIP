class AddImageTime < ActiveRecord::Migration[5.2]
  def self.up
    add_column :marks, :mark_time, :string
  end
  def self.down
    remove_column :marks, :mark_time
  end
end
