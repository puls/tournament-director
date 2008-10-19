class AddRecordHoldover < ActiveRecord::Migration
  def self.up
  	add_column :tournaments, :playoffs_holdover_records, :boolean
  end

  def self.down
  	drop_column :tournaments, :playoffs_holdover_records
  end
end
