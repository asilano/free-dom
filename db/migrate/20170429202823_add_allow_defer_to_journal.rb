class AddAllowDeferToJournal < ActiveRecord::Migration
  def change
    add_column :journals, :allow_defer, :boolean, default: false
  end
end
