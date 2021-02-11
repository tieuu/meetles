class CreateFares < ActiveRecord::Migration[6.0]
  def change
    create_table :fares do |t|
      t.time :duration
      t.integer :fee
      t.references :result_station, null: false, foreign_key: true
      t.references :station, null: false, foreign_key: true

      t.timestamps
    end
  end
end
