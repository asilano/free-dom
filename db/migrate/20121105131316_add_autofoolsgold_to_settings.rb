class AddAutofoolsgoldToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :autofoolsgold, :integer, :default => Settings::ALWAYS
  end
end
