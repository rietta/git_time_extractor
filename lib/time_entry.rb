class TimeEntry < OpenStruct

  def to_partial_path
    'git/time_entry'
  end

  def date
    #Date.parse(self[:date].to_s.strip) if self[:date]
    self[:date]
  end

  def in_week?(week)
    week.week_num == self[:week_number] && week.year == self[:year]
  end

  def story_ids
    self[:story_ids]
  end

  def stories
    story_ids.split(';')
    #story_ids.to_a
  end
end # TimeEntry