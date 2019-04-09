class AddAdmin < ActiveRecord::Migration[5.2]
  def self.up
    create_table :admins do |t|
      t.string :login
      t.string :password
    end
  end

  def self.down
    drop_table :admins
  end
end
