class AddCssClassToHistory < ActiveRecord::Migration
  def self.up
    add_column :histories, :css_class, :string
  end

  def self.down
    remove_column :histories, :css_class
  end
end
