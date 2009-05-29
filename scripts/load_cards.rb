#!/usr/bin/ruby

require 'rubygems'
require 'couchrest'
require 'enumerator'

db = CouchRest.database!('http://localhost:5984/qbtd')
docs = []

def to_id(name)
  name.gsub(/\s+/, '_').downcase.gsub(/[^a-z0-9_]/,'')
end

ARGF.each do |line|
  fields = line.chomp.split(/,/)
  room = fields.shift
  docs << {
    :type => 'room',
    '_id' => "room_#{to_id room}",
    :name => room
  }
  round = 1
  fields.each_slice(2) do |cards|
    docs << {
      '_id' => "game_#{round}_#{to_id room}_#{cards[0]}_#{cards[1]}",
      :type => 'game',
      :team1 => {
        :card => cards[0].to_i
      },
      :team2 => {
        :card => cards[1].to_i
      },
      :room => room,
      :round => round
    }
    round += 1
  end
end
db.bulk_save(docs)