class Initial < ActiveRecord::Migration
  def self.up
    create_table :brackets do |t|
      t.string :name
      t.integer :ordering
    end
    
    create_table :games do |t|
      t.references :round, :bracket, :room
      t.integer :tossups
      t.boolean :play_complete, :entry_complete, :extragame, :overtime, :playoffs, :forfeit, :ignore_indivs
      t.integer :serial_number
    end
    
    create_table :player_games do |t|
      t.references :player, :team_game
      t.integer :tossups_heard
    end
    
    create_table :players do |t|
      t.references :team
      t.string :name
      t.string :future_school
      t.integer :year
      t.integer :qpin
    end
    
    create_table :question_types do |t|
      t.integer :value
      t.string :name
    end
    
    create_table :rooms do |t|
      t.string :name
      t.text :staff
    end
    
    create_table :rounds do |t|
      t.integer :number
      t.boolean :play_complete
    end
    
    create_table :schools do |t|
      t.string :name
      t.string :city
      t.boolean :small
    end
    
    create_table :stat_lines do |t|
      t.references :question_type, :player_game
      t.integer :number
    end
    
    create_table :team_games do |t|
      t.references :team, :game
      t.integer :card
      t.integer :points, :tossups_correct, :tossup_points, :bonus_points
    end
    
    create_table :teams do |t|
      t.references :school
      t.string :name
    end
  end

  def self.down
    drop_table :brackets, :games, :player_games, :players, :question_types, :rooms, :rounds, :schools, :stat_lines, :team_games, :teams, :tournaments
  end
end
