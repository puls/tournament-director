class AddBracketPlayoffLabel < ActiveRecord::Migration
  def self.up
  	add_column :brackets, :playoff_bracket, :boolean
  end

  def self.down
  	drop_column :brackets, :playoff_bracket
  end
end
