class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :level
      t.integer :user_id
      t.integer :contact_id
    end
  end
end
