class CreateObservations < ActiveRecord::Migration[6.1]
  def change
    create_table :observations do |t|
      t.integer :sno
      t.date :observation_date
      t.string :province
      t.string :country
      t.datetime :last_update
      t.integer :confirmed
      t.integer :deaths
      t.integer :recovered
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end

    add_index :observations, [:sno], unique: true
  end
end
