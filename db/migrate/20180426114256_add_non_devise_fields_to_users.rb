class AddNonDeviseFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :name, :string
    add_column :users, :last_completed, :datetime
    add_column :users, :admin, :boolean, default: false
    add_column :users, :contact_me, :boolean, default: false
  end
end
