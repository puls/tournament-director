class QuestionType < ActiveRecord::Base
  has_many :stat_lines
  belongs_to :tournament

  def self.configure_for_power(tournament_id, power = true)
    if (power)
      self.find_or_create_by_value_and_name_and_tournament_id(15,15,tournament_id)
    else
      fifteen = self.find_by_value_and_tournament_id(15, tournament_id)
      fifteen.destroy unless fifteen.nil?
    end

    self.find_or_create_by_value_and_name_and_tournament_id(10,10,tournament_id)
    self.find_or_create_by_value_and_name_and_tournament_id(-5,-5,tournament_id)
  end

end
