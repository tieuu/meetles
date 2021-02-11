class CreateMeetles < ActiveRecord::Migration[6.0]
  def change
    create_table :meetles do |t|
      t.date :date_time
      t.string :activity
      t.boolean :active
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
