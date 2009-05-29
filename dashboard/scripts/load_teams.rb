#!/usr/bin/ruby

require 'rubygems'
require 'couchrest'
require 'enumerator'

db = CouchRest.database!('http://localhost:5984/qbtd')
docs = {}

def to_id(name)
  name.gsub(/\s+/, '_').downcase.gsub(/[^a-z0-9_]/,'')
end

ARGF.each do |line|
  (initial_card, team, city, state, small) = line.chomp.split(/;/)
  initial_card = initial_card.to_i
  school = if team.match(/ [A-Z]$/)
    team.sub(/ [A-Z]$/, '')
  else
    team
  end
  
  team_id = to_id('team_' + team)
  
  if docs[school]
    docs[school][:teams][team_id] = {
      :name => team
    }
  else
    docs[school] = {
      :name => school,
      '_id' => to_id('school_' + state + ' ' + school),
      :type => 'school',
      :city => city,
      :small => (small == '1' ? true : false),
      :teams => {
        team_id => {
          :name => team
        }
      }
    }
  end
  
  game = db.view('qbtd-couch/next_game_for_card', :group => true, :startkey => initial_card, :endkey => initial_card)['rows'][0]['value'][1]
  if game['team1']['card'] == initial_card
    game['team1']['id'] = team_id
    game['team1']['name'] = team
  elsif game['team2']['card'] == initial_card
    game['team2']['id'] = team_id
    game['team2']['name'] = team
  end
  db.save_doc game
end
db.bulk_save(docs.values)