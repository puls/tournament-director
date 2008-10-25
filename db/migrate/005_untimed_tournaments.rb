class UntimedTournaments < ActiveRecord::Migration
  def self.up
  	add_column :tournaments, :questions_per_round, :integer
  end

  def self.down
  	drop_column :tournaments, :questions_per_round
  end
end
