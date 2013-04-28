#!/usr/bin/ruby

require 'rubygems'
require 'couchrest'
require 'enumerator'
require 'csv'

db = CouchRest.database!('http://localhost:5984/qbtd')

File.open('/Users/puls/Desktop/indstats', 'w') do |indstats|
  File.open('/Users/puls/Desktop/scores', 'w') do |scores|
    File.open('/Users/puls/Desktop/teams', 'w') do |teams|

      db.view('app/livestat')['rows'].each do |row|
        key = row['key']
        case key.shift
        when 'indstats'
          indstats.puts CSV.generate_line(key)
        when 'scores'
          scores.puts CSV.generate_line(key)
        when 'teams'
          teams.puts CSV.generate_line(key)
        end
      end

    end
  end
end
