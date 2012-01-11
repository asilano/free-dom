class AddVisibilityDefaultsToCards < ActiveRecord::Migration
  def change
    [:revealed, :peeked].each do |column|
      change_column_default :cards, column, false
    end
  end
end
