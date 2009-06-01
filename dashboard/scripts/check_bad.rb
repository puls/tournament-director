#!/usr/bin/ruby

require 'rubygems'
require 'couchrest'
require 'enumerator'
require 'csv'

db = CouchRest.database!('http://localhost:5984/qbtd')
docs = {}

def to_id(name)
  name.gsub(/\s+/, '_').downcase.gsub(/[^a-z0-9_]/,'')
end
db.view('dashboard/all_games', {:include_docs => true})['rows'].each do |row|
  doc = row['doc']
  if (doc['type'] && doc['type'] == 'game' && doc['entry_complete'])
    if doc['team1']['id'] != to_id("team_#{doc['team1']['name']}")
      puts "Problem! [#{doc['round']},#{doc['room']}]\n#{doc.inspect}"
    end

    if doc['team2']['id'] != to_id("team_#{doc['team2']['name']}")
      puts "Problem! [#{doc['round']},#{doc['room']}]\n#{doc.inspect}"
    end
  end
end