module StatisticsHelper

	def fmt(val)
		val.kind_of?(Numeric) ? sprintf("%.2f",val) : val
	end

end
