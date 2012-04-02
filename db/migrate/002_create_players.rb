class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.column :game_id, :integer
      t.column :name, :string
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :players
  end
end
