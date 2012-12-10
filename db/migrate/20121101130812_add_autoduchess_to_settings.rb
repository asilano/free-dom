class AddAutoduchessToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :autoduchess, :integer, :default => Settings::ASK
  end
end
