#!/usr/bin/ruby

require 'rubygems'
require 'couchrest'
require 'enumerator'
require 'csv'

db = CouchRest.database!('http://localhost:5984/hsnct11')
docs = {}

def to_id(name)
  name.gsub(/\s+/, '_').downcase.gsub(/[^a-z0-9_]/,'')
end

team_count = ARGF.gets.to_i
while (team_count > 0)
  player_count = ARGF.gets.to_i - 1
  match = ARGF.gets.chomp.match /(.+?)( \[SS\])?$/
  team = match[1]
  small = !match[2].nil?
  team_id = to_id('team_' + team)
  school = team.match(/(.+?)( [A-Z])?$/)[1]
  players = {}
  while (player_count > 0)
    line = ARGF.gets.chomp
    match = line.match(/([^\(]+)( \((\d+)\))?$/)
    player = match[1]
    player_key = to_id('player_' + team + '_' + player)
    player_year = match[3]
    players[player_key] = {
      :name => player,
      :year => player_year
    }
    player_count -= 1
  end
  team_count -= 1
  
  if docs[school]
    docs[school][:teams][team_id] = {
      :name => team,
      :players => players
    }
  else
    docs[school] = {
      :name => school,
      '_id' => to_id('school_' + school),
      :type => 'school',
      :city => "",
      :small => small,
      :teams => {
        team_id => {
          :name => team,
          :players => players
        }
      }
    }
  end
  
end

db.bulk_save(docs.values)