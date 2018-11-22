class CreateMarks < ActiveRecord::Migration[5.2]
  def self.up
    create_table :marks do |t|
      t.string :car_number
      t.timestamps
    end
  end

  def self.down
    drop_table :marks
  end
end