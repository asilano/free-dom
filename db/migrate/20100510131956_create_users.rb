class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :hashed_password
      t.string :salt

      t.timestamps
    end
    
    remove_column :players, :pass_hash
    remove_column :players, :salt
    remove_column :players, :name
    
    add_column :players, :user_id, :integer
  end

  def self.down
    drop_table :users
    add_column :players, :name, :string
    add_column :players, :salt, :string
    add_column :players, :pass_hash, :string    
  end
end
