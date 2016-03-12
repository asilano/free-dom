class AddOrderToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :order, :integer
  end
end
