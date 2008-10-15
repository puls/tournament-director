class AddUsesCards < ActiveRecord::Migration
  def self.up
  	add_column :tournaments, :uses_cards, :boolean
  end

  def self.down
  	drop_column :tournaments, :uses_cards
  end
end
