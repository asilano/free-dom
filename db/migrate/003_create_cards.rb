class CreateCards < ActiveRecord::Migration
  def self.up
    create_table :cards do |t|
      t.column :game_id, :integer
      t.column :player_id, :integer
      t.column :pile_id, :integer
      t.column :location, :string
      t.column :position, :integer
      t.column :type, :string
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :cards
  end
end
