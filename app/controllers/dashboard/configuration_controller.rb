class Dashboard::ConfigurationController < DashboardController

  before_filter :load_configuration

  def index
    #redirect_to :controller => 'dashboard/entry'
  end

  def list_tournaments
    @tournaments = Tournament.find(:all)
  end

  def select_tournament
    session[:tournament_id] = params['id']
    flash[:notice] = "Active tournament changed."
    redirect_to :controller => 'dashboard/entry'
  end

  def new_tournament
    @tournament = nil
    add_default_configuration
    @tournament.save
    session['tournament_id'] = @tournament.id
    flash[:notice] = "New tournament created."
    redirect_to :action => 'edit_tournaments'
  end

  def edit_tournaments
    add_default_configuration
  end

  def save_tournament
    add_default_configuration
    @tournament.update_attributes(params['tournament'])
    QuestionType.configure_for_power(@tournament.id, @tournament.powers)
    @tournament.bracketed = false if (params['bracket_names'].nil?)
    if @tournament.bracketed?
      brackets_to_delete = @tournament.brackets
      for name in params['bracket_names']
        next if name.empty?
        bracket = @tournament.brackets.find(:conditions => ['name = ?',name]) || @tournament.brackets.build(:name => name)
        bracket.save
        brackets_to_delete.delete(bracket)
      end
      brackets_to_delete.each {|b| b.destroy}
    else
      @tournament.brackets.clear
    end
    @tournament.bracketed = false if @tournament.brackets.empty?
    @tournament.save
    flash[:notice] = "Tournament saved."
    redirect_to :action => "edit_tournaments"
  end

  def edit_teams
    if @tournament.nil?
      redirect_to :action => 'edit_tournaments'
    end
  end

  def save_teams

  end

  private
  def add_default_configuration
    @tournament ||= Tournament.new
    @brackets = @tournament.brackets.count > 0 ? @tournament.brackets : [@tournament.brackets.build,@tournament.brackets.build]
  end

end
