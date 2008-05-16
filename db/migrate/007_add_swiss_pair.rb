class AddSwissPair < ActiveRecord::Migration
  def self.up
  	add_column :tournaments, :swiss, :boolean
  end

  def self.down
  	drop_column :tournaments, :swiss
  end
end
