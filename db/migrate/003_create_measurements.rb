class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.references :user
      t.float :blood_oxygenation
      t.float :pulse_rate
      t.timestamps
    end
  end
end
