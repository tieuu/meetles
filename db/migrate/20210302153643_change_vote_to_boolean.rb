class ChangeVoteToBoolean < ActiveRecord::Migration[6.0]
  def change
    change_column :result_stations, :vote, :boolean
  end
end
