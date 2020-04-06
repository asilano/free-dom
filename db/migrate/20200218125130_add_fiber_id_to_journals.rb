class AddFiberIdToJournals < ActiveRecord::Migration[5.2]
  def change
    add_column :journals, :fiber_id, :string
  end
end
