class CreateCustomers < ActiveRecord::Migration[6.1]
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email

      t.timestamps
    end
  end
end
#       t.integer :account_id, limit: 8, null: false
#       t.binary :contact_id, limit: 16, null: false
#       t.binary :channel_id, limit: 16, null: false
#       t.date :deleted_at