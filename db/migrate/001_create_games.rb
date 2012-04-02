class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.column :name, :string
      t.column :max_players, :integer
     # 1.upto(10) do |num|
     #   t.column "pile_#{num}".to_sym, :string
     # end
    end
  end

  def self.down
    drop_table :games
  end
end
