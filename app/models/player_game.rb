class PlayerGame < ActiveRecord::Base
  belongs_to :player
  belongs_to :team_game
  has_many :stat_lines, :dependent => :destroy

  validates_presence_of :player
  validates_presence_of :team_game
  validates_presence_of :tossups_heard
  validates_numericality_of :tossups_heard, :only_integer => true

  def stat_line_for(type)
    begin
      stat_lines.detect {|sl| sl.question_type_id == type.id}.number
    rescue ActiveRecord::RecordNotFound
      0
    end
  end
  
  def round_number
    team_game.game.round.number
  end

  def points(types = nil)
    if types.nil?
      types = QuestionType.find(:all)
    end

    types.collect{|type| stat_line_for(type) * type.value}.sum || 0
  end
end
