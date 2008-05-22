def load_tdb(t = :first)
	ApplicationController.new.load_tournament_database Tournament.find(t)
end
