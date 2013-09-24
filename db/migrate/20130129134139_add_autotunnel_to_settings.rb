class AddAutotunnelToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :autotunnel, :integer, :default => Settings::ALWAYS
  end
end
