class Array 
	def sum 
		inject( nil ) { |sum,x| sum ? sum+x : x } 
	end 
end

#module ActionController::Assertions::ModelAssertions
#	def assert_invalid(record)
#		clean_backtrace do
#			assert !(record.valid?), "Should not be valid."
#		end
#	end
#end
