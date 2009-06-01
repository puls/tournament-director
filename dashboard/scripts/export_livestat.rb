#!/usr/bin/ruby

require 'rubygems'
require 'couchrest'
require 'enumerator'
require 'csv'

db = CouchRest.database!('http://localhost:5984/qbtd')

File.open('/Users/jim/Desktop/indstats', 'w') do |indstats|
  File.open('/Users/jim/Desktop/scores', 'w') do |scores|
    File.open('/Users/jim/Desktop/teams', 'w') do |teams|
      
      db.view('statistics/livestat')['rows'].each do |row|
        key = row['key']
        case key.shift
        when 'indstats'
          indstats.puts CSV.generate_line(key.unshift(''))
        when 'scores'
          scores.puts CSV.generate_line(key.unshift(''))
        when 'teams'
          teams.puts CSV.generate_line(key)
        end
      end

    end
  end
end
