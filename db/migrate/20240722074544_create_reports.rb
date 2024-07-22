class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.string :ticker
      t.string :cik
      t.string :name
      t.integer :year

      t.timestamps
    end
  end
end
