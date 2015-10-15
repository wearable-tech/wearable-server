class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.references :user
      t.references :contact
      t.integer :level
    end
  end
end
