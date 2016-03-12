class AddModifiedToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :modified, :boolean, default: false
  end
end
