class AddAutooracleToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :autooracle, :boolean, :default => false
  end
end
