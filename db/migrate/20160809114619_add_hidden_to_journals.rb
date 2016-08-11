class AddHiddenToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :hidden, :boolean
  end
end
