class AddSmallSchool < ActiveRecord::Migration
  def self.up
  	add_column :schools, :small, :boolean
  end

  def self.down
  	drop_column :schools, :small
  end
end
