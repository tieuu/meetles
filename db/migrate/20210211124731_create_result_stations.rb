class CreateResultStations < ActiveRecord::Migration[6.0]
  def change
    create_table :result_stations do |t|
      t.references :station, null: false, foreign_key: true
      t.references :meetle, null: false, foreign_key: true
      t.integer :vote

      t.timestamps
    end
  end
end
