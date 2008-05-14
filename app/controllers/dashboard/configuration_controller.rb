class Dashboard::ConfigurationController < DashboardController

  before_filter :load_configuration

  def edit_tournaments
    add_default_configuration
  end
  
  def save_tournament
    add_default_configuration
    @tournament.update_attributes(params['tournament'])
    QuestionType.configure_for_power(@tournament.power)
    @tournament.bracketed = false if (params['bracket_names'].nil?)
    if (@tournament.bracketed?)
      brackets_to_delete = Bracket.find(:all)
      for name in params['bracket_names']
        next if name.empty?
        bracket = Bracket.find_by_name(name) || Bracket.new(:name => name)
        bracket.save
        brackets_to_delete.delete(bracket)
      end
      brackets_to_delete.each {|b| b.destroy}
    else
      Bracket.destroy_all
    end
    @tournament.bracketed = false if (Bracket.count == 0)
    @tournament.save
    flash[:notice] = "Tournament saved."
    redirect_to :action => "edit_tournaments"
  end
  
  private
  def add_default_configuration
    @brackets = Bracket.count > 0 ? Bracket.find(:all) : [Bracket.new,Bracket.new]
    @tournament ||= Tournament.new
  end

end
