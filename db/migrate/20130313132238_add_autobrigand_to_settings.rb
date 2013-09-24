class AddAutobrigandToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :autobrigand, :boolean, :default => true
  end
end
