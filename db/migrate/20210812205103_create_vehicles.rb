class CreateVehicles < ActiveRecord::Migration[6.1]
  def change
    create_table :vehicles do |t|
      t.string :vehicle_type
      t.string :name
      t.integer :length

      t.belongs_to :customer
      t.timestamps
    end
  end
end
