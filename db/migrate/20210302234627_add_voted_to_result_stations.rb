class AddVotedToResultStations < ActiveRecord::Migration[6.0]
  def change
    add_column :result_stations, :voted, :boolean
  end
end
