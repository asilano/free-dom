class AddTypeAndParametersToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :type, :string
    add_column :journals, :parameters, :text
  end
end
