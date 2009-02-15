class Dashboard::EntryController < DashboardController

  before_filter :check_configuration
  before_filter :check_teams

  def index
    if params['round']
      @round = Round.find_or_create_by_number(params['round'])
    else
      @round = Round.find(:first, :order => 'number', :conditions => ["play_complete is null or play_complete != ?", true])
    end

    if (@round.nil?)
      @round = Round.find(:first, :order => 'number desc')
    end

    if(@round.nil?)
      @round = Round.create(:number => 1)
    end
    
    if not params['round'] and not $tournament.uses_cards? and @round.number != 1 and not @round.play_complete? then
      @round = Round.find(:first, :conditions => ['number = ?', @round.number - 1])
    end

    @complete_games = Game.find(:all, :order => 'teams.name', :include => [:round, {:team_games => :team}], :conditions => ["games.play_complete is not null and games.play_complete = ? and (games.entry_complete is null or games.entry_complete != ?)", true, true])

    if $tournament.uses_cards? then
      @incomplete_games = Game.find(:all, :include => [:room, {:team_games => :team}], :conditions => ["(play_complete is null or play_complete != ?) and round_id = ?", true, @round.id], :order => 'team_games.ordering')
#      @complete_games = Game.find(:all, :order => 'teams.name', :include => [:round, {:team_games => :team}], :conditions => ["games.play_complete is not null and games.play_complete = ? and (games.entry_complete is null or games.entry_complete != ?)", true, true])

      @teams_for_round = @incomplete_games.collect {|g| g.team_games}.flatten.collect {|tg| ["#{tg.team.name} (#{tg.card})", tg.team.id]}.sort_by {|array| array.first}
      @rooms_for_round = @incomplete_games.collect {|g| g.room}.sort_by {|r| r.name.to_i || r.name}
    else
      @all_teams = Team.find(:all, :order => 'teams.name', :include => [{:team_games => {:game => :bracket}}])
      @games_done_for_round = Game.find(:all, :include => [:room, {:team_games => :team}], :conditions => ["(play_complete = ?) and round_id = ?", true, @round.id])
      @teams_done_for_round = @games_done_for_round.collect {|g| g.team_games}.flatten.collect {|tg| tg.team}

      for team in @teams_done_for_round
        @all_teams.delete team
      end

      @teams_for_round = @all_teams.collect {|t| ["#{t.name}", t.id]}.sort_by {|array| array.first}

      @rooms_for_round = Room.find(:all)

      for game in @games_done_for_round
        @rooms_for_round.delete game.room
      end

      @rooms_for_round.sort_by {|r| r.name.to_i || r.name}
      @incomplete_games = []

      if $tournament.bracketed? then
        @latest_bracket_for_team = @all_teams.collect{|team| [team, team.team_games.collect {|tg| tg.game}.sort_by {|g| g.round.number }.last]}.collect{|team| [team[0], team[1].nil? ? nil : team[1].bracket]}
      else
        @latest_bracket_for_team = []
      end
    end
  end

  def entry_for_round
    index
    render :partial => "enter_game"
  end

  def rooms_for_round
    @rooms = Room.find(:all)
    render :partial => "room_option", :collection => @rooms, :locals => {:selected => params[:selected]}
  end

  def save_game
    if (params[:id])
      begin
        @game = Game.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @game = nil
      end
    end

    was_incomplete = @game.nil? || !@game.play_complete?

    if params[:round_number].empty?
      flash[:error] = "Round number cannot be empty."
      redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
      return false
    end

    round = Round.find_or_create_by_number(params[:round_number])

    if params[:team1] == params[:team2]
      flash[:error] = "You cannot select the same team for both slots."
      redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
      return false
    end

    if params[:score1].to_i == params[:score2].to_i and not params[:forfeit]
      flash[:error] = "Scores cannot be equal in a non-forfeit."
      redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
      return false
    end

    if @game.nil?
      game = round.games.build(:round => round, :tossups => params[:tossups], :extragame => params[:extragame], :overtime => params[:overtime], :playoffs => params[:playoffs], :forfeit => params[:forfeit], :play_complete => true)
      game.room = Room.find(params[:room]) if $tournament.tracks_rooms?
      game.bracket = Bracket.find(params[:bracket]) if $tournament.bracketed?
    else
      game = @game
      game.update_attributes(:round => round, :tossups => params[:tossups], :extragame => params[:extragame], :overtime => params[:overtime], :playoffs => params[:playoffs], :forfeit => params[:forfeit], :play_complete => true)
      game.room = Room.find(params[:room]) if $tournament.tracks_rooms?
      game.bracket = Bracket.find(params[:bracket]) if $tournament.bracketed?
    end

    unless game.save
      flash[:error] = game.errors.full_messages.join("<br />\n")
      redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
      return false
    end

    if @game.nil?
      tg1 = game.team_games.build(:team => Team.find(params[:team1]), :points => params[:score1], :ordering => 1)
      tg2 = game.team_games.build(:team => Team.find(params[:team2]), :points => params[:score2], :ordering => 2)
    else
      tg1 = game.team_games.find_by_team_id(params[:team1])
      tg1.update_attributes(:points => params[:score1], :ordering => 1)

      tg2 = game.team_games.find_by_team_id(params[:team2])
      tg2.update_attributes(:points => params[:score2], :ordering => 2)
    end

    if tg1.points > tg2.points
      tg1.won = true
      tg2.won = false
    else
      tg1.won = false
      tg2.won = true
    end

    if not tg1.save
      flash[:error] = tg1.errors.full_messages.join("<br />\n")
      game.destroy if @game.nil?
      redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
      return false
    end

    if not tg2.save
      flash[:error] = tg2.errors.full_messages.join("<br />\n")
      game.destroy if @game.nil?
      redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
      return false
    end

    if $tournament.swiss? && !tg1.card.nil? && !tg2.card.nil?
      next_tg1 = TeamGame.find(:first,
        :conditions => ["card = ? AND rounds.number >= ? AND team_id IS NULL", [tg1.card, tg2.card].min, round.number + 1],
        :include => {:game => :round},
        :order => "rounds.number")
      unless (next_tg1.nil?)
        next_tg1.team = tg1.won? ? tg1.team : tg2.team
        next_tg1.save
      end

      next_tg2 = TeamGame.find(:first,
        :conditions => ["card = ? AND rounds.number >= ? AND team_id IS NULL", [tg1.card, tg2.card].max, round.number + 1],
        :include => {:game => :round},
        :order => "rounds.number")
      unless (next_tg2.nil?)
        next_tg2.team = tg1.won? ? tg2.team : tg1.team
        next_tg2.save
      end
    end

    if (Game.count(:conditions => ["round_id = ? and (play_complete is null or play_complete != ?)", round.id, true]) == 0)
      round.play_complete = true
      round.save
    end

    expire_page :controller => '/statistics', :action => 'standings'
    expire_page :controller => '/statistics', :action => 'team', :id => tg1.team.id
    expire_page :controller => '/statistics', :action => 'team', :id => tg2.team.id
    expire_page :controller => '/statistics', :action => 'scoreboard'
    flash[:notice] = "Game saved."
    redirect_to was_incomplete ? {:action => 'index'} : {:action => 'status'}
  end

  def ignore_indivs
    begin
      @game = Game.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Game not found to ignore."
      redirect_to :action => 'index'
      return false
    end

    @game.ignore_indivs = true
    @game.save

    if not @game.errors.empty?
      flash[:error] = @game.errors.full_messages.join("<br />\n")
    end

    redirect_to :action => 'index'
  end

  def enter_players
    begin
      @game = Game.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "The requested game was not found."
      redirect_to :action => 'index'
      return false
    end

    if @game.ignore_indivs
      flash[:error] = "The selected game has been marked as ignored."
      redirect_to :action => 'index'
      return false
    end

    @teamgame1 = @game.team_games[0]
    @teamgame2 = @game.team_games[1]
    @team1 = @teamgame1.team
    @team2 = @teamgame2.team
    @types = QuestionType.find(:all, :order => 'value desc')
  end

  def save_players
    @types = QuestionType.find(:all, :order => 'value desc')

    # Parse the input

    game = Game.find(params[:id], :include => [{:team_games => :team}])
    teams = params[:team]
    bothteams = Array.new
    team_games = Hash.new
    player_games = Array.new
    for index in teams.keys
      team = game.teams.find(teams[index])
#      team_game = TeamGame.find_by_game_id_and_team_id(game.id, team.id)
      team_game = game.team_games.select{|tg| tg.team == team}.first
      team_games[team.id] = team_game
      for player_line in params["teamData"][index].values
        fields = player_line.split(",")
        name = fields.shift
        player = team.players.find_or_create_by_name(name)
        player_game = team_game.player_games.create(:player => player, :tossups_heard => fields.shift)

        if player_game.tossups_heard > game.tossups
          #fail
          flash[:error] = "Player tossups heard were greater than game tossups heard."
          redirect_to :action => 'enter_players', :id => game.id
          player_game.destroy
          player_games.each{|pg| pg.destroy}
          return false;
        end

        for type in @types
          line = player_game.stat_lines.create(:question_type => type, :number => fields.shift)
        end

        if player_game.stat_lines.collect{|sl| sl.number}.sum > player_game.tossups_heard
          #fail
          flash[:error] = "Player answered more tossups than tossups heard."
          redirect_to :action => 'enter_players', :id => game.id
          player_game.destroy
          player_games.each{|pg| pg.destroy}
          return false;
        end

        player_games.push player_game
      end
      bothteams.push team
    end

    # Validate the input

    # tossups answered correctly by team
    total_tossups = Hash.new
    for team in bothteams
      total_tossups[team.id] =  player_games.select{|pg| pg.player.team.id == team.id}.collect{|pg| pg.stat_lines.clone.select{|sl| sl.question_type.value > 0}.collect{|sl| sl.number}}.flatten.sum
    end

    # tossups answered correctly and negged on by team
    total_answered = Hash.new
    for team in bothteams
      total_answered[team.id] = player_games.select{|pg| pg.player.team.id == team.id}.collect{|pg| pg.stat_lines.clone.collect{|sl| sl.number}}.flatten.sum
    end

    total_tossups_heard = player_games.clone.collect{|pg| pg.tossups_heard}.sum

    # tossup points and bonus points by team
    tossup_points = Hash.new
    bonus_points = Hash.new
    for team in bothteams
      tossup_points[team.id] = player_games.clone.select{|pg| pg.player.team.id == team.id}.collect{|pg| pg.stat_lines.collect{|sl| sl.question_type.value * sl.number}}.flatten.sum
      bonus_points[team.id] = team_games[team.id].points - tossup_points[team.id]
    end

    if total_tossups.values.sum > game.tossups
      # fail
      flash[:error] = "More tossups were answered correctly than were asked."
      redirect_to :action => 'enter_players', :id => game.id
      player_games.each{|pg| pg.destroy}
      return false;
    end

    if total_tossups_heard > (8 * game.tossups)
      #fail
      flash[:error] = "More tossups were heard by all players than the maximum possible."
      redirect_to :action => 'enter_players', :id => game.id
      player_games.each{|pg| pg.destroy}
      return false;
    end

    for team in bothteams
      if total_answered[team.id] > game.tossups
        #fail
        flash[:error] = "More tossups were answered by the team than were asked."
        redirect_to :action => 'enter_players', :id => game.id
        player_games.each{|pg| pg.destroy}
        return false;
      end

      if total_tossups[team.id] == 0 and bonus_points[team.id] > 0
        #fail
        flash[:error] = "Team has bonus points without any correct tossups."
        redirect_to :action => 'enter_players', :id => game.id
        player_games.each{|pg| pg.destroy}
        return false;
      elsif total_tossups[team.id] > 0
        bonus_points_per_tossup = (bonus_points[team.id]/total_tossups[team.id])
        if bonus_points_per_tossup < 0.0 or bonus_points_per_tossup > 30.0
          #fail
          flash[:error] = "Bonus points per tossup correct is out of range 0-30"
          redirect_to :action => 'enter_players', :id => game.id
          player_games.each{|pg| pg.destroy}
          return false;
        end
      end
    end

    game.team_games.each do |tg|
      tg.update_attributes(:tossups_correct => total_tossups[tg.team.id], :tossup_points => tossup_points[tg.team.id], :bonus_points => bonus_points[tg.team.id])
    end

    game.entry_complete = true
    game.save
    expire_page :controller => '/statistics', :action => 'personal'
    flash[:notice] = "Individual standings saved."
    redirect_to :action => 'index'
  end

  # Will list all entered games and link for editing
  def status
    @rounds = Round.find(:all, :include => [{:games => [{:team_games => :team} ]}], :order => 'number, team_games.ordering', :conditions => ['games.play_complete = ?', true])
  end

  def edit_game
    begin
      @game = Game.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Game was not found."
      redirect_to :action => 'status'
    end

    @last_round = @game.round.number
  end

  def delete_game
    begin
      @game = Game.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Game was not found."
      redirect_to :action => 'status'
    end

    @game.destroy

    expire_page :controller => '/statistics', :action => 'standings'
    expire_page :controller => '/statistics', :action => 'team', :id => tg1.team.id
    expire_page :controller => '/statistics', :action => 'team', :id => tg2.team.id
    expire_page :controller => '/statistics', :action => 'scoreboard'
    flash[:notice] = "Game was deleted successfully."
    redirect_to :action => 'status'
  end

  def clear_indivs
    begin
      @game = Game.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Game was not found."
      redirect_to :action => 'status'
    end

    @game.team_games.each do |tg|
      tg.player_games.each do |pg|
        pg.destroy
      end
    end

    @game.update_attributes :entry_complete => false

    expire_page :controller => '/statistics', :action => 'personal'
    flash[:notice] = "Individual stats were cleared for that game."
    redirect_to :action => 'status'

  end

end
