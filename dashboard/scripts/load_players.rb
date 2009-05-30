#!/usr/bin/ruby

require 'rubygems'
require 'couchrest'
require 'enumerator'
require 'csv'

db = CouchRest.database!('http://localhost:5984/qbtd')

def to_id(name)
  name.gsub(/\s+/, '_').downcase.gsub(/[^a-z0-9_]/,'')
end

docs = db.view('dashboard/by_school_name')['rows'].inject({}) do |hash, row|
  hash[row['key']] = row['value']
  hash
end

ARGF.each do |line|
  (team, player, year, future, confirmed) = CSV.parse(line.chomp).first

  school = if team.match(/ [A-Z]$/)
    team.sub(/ [A-Z]$/, '')
  else
    team
  end
  
  key = to_id('team_' + team)
  
  docs[school]['teams'][key]['players'] ||= {}
  
  player_key = to_id('player_' + team + '_' + player)
  
  docs[school]['teams'][key]['players'][player_key] = {
    :name => player,
    :year => year,
    :school => future
  }
  
end

db.bulk_save(docs.values)