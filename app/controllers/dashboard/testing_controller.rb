class Dashboard::TestingController < DashboardController

	before_filter :load_configuration

	def index
	
	end
	
	def load_test_data
	
		if params[:sure]
			# Create Brackets
			@tournament.bracketed = true
			Bracket.destroy_all
			brackets = []
			for i in 1..2
				brackets[i-1] = Bracket.new(:name => "Bracket #{i}", :ordering => i)
				brackets[i-1].save
			end
			
			# Create Cards
			@tournament.swiss = true
			cards = []
			for i in 1..150
				cards[i-1] = i
			end
			
			# Create Rooms
			@tournament.tracks_rooms = true
			Room.destroy_all
			rooms = []
			for i in 1..75
				rooms[i-1] = Room.new(:name => "Room #{i}", :staff => "Staff #{i}")
				rooms[i-1].save
			end
			
			@tournament.save
		
			# Create Schools
			School.destroy_all
			schools = []
			for i in 1..50
				schools[i-1] = School.new(:name => "School #{i}", :city => "Test #{i}", :small => false)
				schools[i-1].save
			end

			# Create Teams
			for i in 1..50
				for j in 1..3
					schools[i-1].teams.create(:name => "School #{i} #{j}")
				end
			end
			
			# Create Players
			for i in 1..50
				for j in 1..3
					for k in 1..4
						schools[i-1].teams[j-1].players.create(:name => "Player #{k}")
					end
				end
			end
			
			# Create Rounds
			Round.destroy_all
			rounds = []
			for i in 1..11
				rounds[i-1] = Round.new(:number => i)
				rounds[i-1].save
			end
			
			# Create Games
			Game.destroy_all
			for i in 1..11 # rounds
				teams2 = Team.find(:all).clone
				cards2 = cards.clone
				for j in 1..75 # games
					game = rounds[i-1].games.create(:bracket => brackets[j % 2], :room => rooms[j-1], :tossups => 18 + rand(8), :play_complete => true)
					card1 = cards2[rand(cards2.size)]
					cards2.delete(card1)
					card2 = cards2[rand(cards2.size)]
					cards2.delete(card2)
					team1 = Team.find(teams2[rand(teams2.size)].id)
					teams2.delete(team1)
					team2 = Team.find(teams2[rand(teams2.size)].id)
					teams2.delete(team2)
					game.team_games.create(:card => card1, :team => team1, :points => 300, :ordering => 1, :won => false)
					game.team_games.create(:card => card2, :team => team2, :points => 400, :ordering => 2, :won => true)
				end
			end
			
			redirect_to :controller => 'dashboard/entry'
		end
	end
	
end
