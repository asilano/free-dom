class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.integer :user_id
      t.integer :player_id
      t.boolean :automoat, :default => true
      t.boolean :autocrat_victory, :default => true
      t.boolean :autocrat_show, :default => true
    end
  end

  def self.down
    drop_table :settings
  end
end
