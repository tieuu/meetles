class AddCodeToStation < ActiveRecord::Migration[6.0]
  def change
    add_column :stations, :code, :string
  end
end
