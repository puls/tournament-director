class Tournament < ActiveRecord::Base
  after_save :cleanup_assocs

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_presence_of :database
  validates_uniqueness_of :database
  validates_numericality_of :tuh_cutoff, :only_integer => true, :allow_nil => true

  def cleanup_assocs
    begin
      if not bracketed?
        Bracket.destroy_all
      end

      if not tracks_rooms?
        Room.destroy_all
      end
    rescue ActiveRecord::StatementInvalid
      # okay to drop this
    end
  end

end
