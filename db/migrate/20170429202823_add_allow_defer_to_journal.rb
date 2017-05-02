class AddAllowDeferToJournal < ActiveRecord::Migration
  def change
    add_column :journals, :allow_defer, :boolean
    add_column :journals, :default, :false
  end
end
