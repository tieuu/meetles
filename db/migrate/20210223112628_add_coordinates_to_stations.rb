class AddCoordinatesToStations < ActiveRecord::Migration[6.0]
  def change
    add_column :stations, :latitude, :float
    add_column :stations, :longitude, :float
  end
end
