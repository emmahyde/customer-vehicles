class AddPrimaryToVehicles < ActiveRecord::Migration[6.1]
  def change
    add_column :vehicles, :primary, :boolean, default: false
  end
end
