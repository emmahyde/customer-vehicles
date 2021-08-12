class AddUniqEmailToCustomers < ActiveRecord::Migration[6.1]
  def change
    add_column :customers, :email, :string
    add_index :customers, :email, unique: true
  end
end
