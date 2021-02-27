class AddCoordinatesToResultStations < ActiveRecord::Migration[6.0]
  def change
    add_column :result_stations, :latitude, :float
    add_column :result_stations, :longitude, :float
  end
end
