class AddPlayoffIndivsOption < ActiveRecord::Migration
  def self.up
  	add_column :tournaments, :count_playoffs_for_personal, :boolean
  end

  def self.down
  	drop_column :tournaments, :count_playoffs_for_personal
  end
end
