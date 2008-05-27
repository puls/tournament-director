class WelcomeController < ApplicationController

  before_filter :load_configuration
  before_filter :get_school_lists

  def index
  end

  def get_school_lists
    @all_schools = School.find(:all, :order => 'name')
    @schools_check_in = @all_schools.select{|s| not s.checked_in?}
    @schools_roster_check = @all_schools.select{|s| not s.checked_roster?}
    @schools_not_paid = @all_schools.select{|s| not s.paid?}
    @schools_done = @all_schools.select{|s| s.checked_in? and s.checked_roster? and s.paid?}
  end



end
