class AddPowers < ActiveRecord::Migration
  def self.up
    add_column :tournaments, :powers, :boolean
  end

  def self.down
    remove_column :tournaments, :powers
  end
end
