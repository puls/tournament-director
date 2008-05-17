class QuestionType < ActiveRecord::Base
  has_many :stat_lines
  
  validates_numericality_of :value, :only_integer => true

  def self.configure_for_power(power = true)
    if (power)
      self.find_or_create_by_value_and_name(15, 15)
    else
      fifteen = self.find_by_value(15)
      fifteen.destroy unless fifteen.nil?
    end

    self.find_or_create_by_value_and_name(10, 10)
    self.find_or_create_by_value_and_name(-5, -5)
  end

end
