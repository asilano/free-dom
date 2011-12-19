class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.integer :game_id
      t.text :event
      t.timestamp :created_at
    end
  end

  def self.down
    drop_table :histories
  end
end
