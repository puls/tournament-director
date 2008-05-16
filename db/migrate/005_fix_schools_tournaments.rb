class FixSchoolsTournaments < ActiveRecord::Migration
  def self.up
  	rename_table :tournament_schools, :schools_tournaments
  end

  def self.down
  	rename_table :schools_tournaments, :tournament_schools
  end
end
