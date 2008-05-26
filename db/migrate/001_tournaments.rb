class Tournaments < ActiveRecord::Migration
  def self.up
    create_table :tournaments do |t|
      t.string :name
      t.boolean :timed, :bracketed, :ping_stats, :ping_contact, :includes_years, :swiss, :powers, :tracks_rooms
      t.string :database
      t.integer :tuh_cutoff
      t.text :welcome_content
    end
  end

  def self.down
    drop_table :tournaments
  end
end
