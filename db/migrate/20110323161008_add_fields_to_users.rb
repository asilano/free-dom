class AddFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email, :string
    add_column :users, :contact_me, :boolean, :default => false
    add_column :users, :last_completed, :timestamp
  end

  def self.down
    remove_column :users, :last_completed
    remove_column :users, :contact_me
    remove_column :users, :email    
  end
end
