class AddTournamentAssocs < ActiveRecord::Migration
  def self.up
    add_column :brackets, :tournament_id, :reference
    add_column :cards, :tournament_id, :integer
    add_column :rounds, :tournament_id, :integer
    add_column :question_types, :tournament_id, :integer
    add_column :teams, :tournament_id, :integer
    add_column :rooms, :tournament_id, :integer
  end

  def self.down
    drop_column :brackets, :tournament_id
    drop_column :cards, :tournament_id
    drop_column :rounds, :tournament_id
    drop_column :question_types, :tournament_id
    drop_column :teams, :tournament_id
    drop_column :rooms, :tournament_id
  end
end
