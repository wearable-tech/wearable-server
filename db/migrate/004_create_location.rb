class CreateLocation < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.references :user
      t.float :latitude
      t.float :longitude
      t.timestamps
    end
  end
end
