class AddKanjiNameToStations < ActiveRecord::Migration[6.0]
  def change
    add_column :stations, :name_kanji, :string
  end
end
