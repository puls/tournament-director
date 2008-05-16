class TournamentSchools < ActiveRecord::Migration
  def self.up
  	create_table :tournament_schools do |t|
  		t.references :school, :tournament
  	end
  end

  def self.down
  	drop_table :tournament_schools
  end
end
