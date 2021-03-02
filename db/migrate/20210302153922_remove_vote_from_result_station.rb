class RemoveVoteFromResultStation < ActiveRecord::Migration[6.0]
  def change
    remove_column :result_stations, :vote
  end
end
