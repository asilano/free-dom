class AddAutoiggToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :autoigg, :integer, :default => Settings::ASK
  end
end
