class AddAutoschemeToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :autoscheme, :boolean, :default => true
  end
end
