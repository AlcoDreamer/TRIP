class CreateUser < ActiveRecord::Migration[5.2]
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :nick
      t.string :email
      t.string :password
      t.string :sex
      t.string :image
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
