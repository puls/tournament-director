module Dashboard::EntryHelper
  include DashboardHelper

  def sort_for_entry(a,b)
    if a.round.number == b.round.number
      a.team_games[0].team.name <=> b.team_games[0].team.name
    else
      a.round.number <=> b.round.number
    end
  end
end
