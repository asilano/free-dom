class ChangeSettings < ActiveRecord::Migration
  def self.up
    change_table :settings do |t|
      t.remove :autocrat_show
      
      t.boolean :autobaron, :default => true
      t.boolean :autotorture_curse, :default => false
      t.boolean :automountebank, :default => true
      t.boolean :autotreasury, :default => true
    end
  end

  def self.down
    change_table :settings do |t|
      t.boolean :autocrat_show, :default => true
      
      t.remove :autobaron
      t.remove :autotorture_curse
      t.remove :automountebank
      t.remove :autotreasury
    end
  end
end
