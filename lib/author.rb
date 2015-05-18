class Author

  attr_accessor :commits, :worklog, :rows, :options

  def initialize(options)
    @options  = options
    @commits  = Array.new
    @worklog  = Hash.new
    @rows     = Array.new
  end

  # Each commit is added into the list
  def add_commit(commit)
    @commits << commit
  end

  def total_commits
    return @commits.length
  end

  def total_working_minutes
    # Go through the work log
    total = 0
    @worklog.keys.sort.each do |date|
      if date_in_filter_range(date)
        total += @worklog[date].duration.to_i
      end
    end # worklog each
    return total
  end
  
  def total_working_hours
    return (total_working_minutes() / 60.0).round(1)
  end

  # Then the tabulation is called after the commits are added into this author's list
  def tabulate_days
    @commits.each_with_index do |commit, index|
       roll_up_to_days commit, index
    end

    # Go through the work log
    @worklog.keys.sort.each do |date|
      if date_in_filter_range(date)
        @rows << summarize(@worklog[date], date)
      end
    end # worklog each
  end # tabulate_days

  def summarize(summary, date)
    start_time = DateTime.parse(date.to_s)
    duration_in_seconds = (summary.duration.to_f * 60.0).round(0)
    duration_in_minutes = summary.duration.to_i
    duration_in_hours   = (summary.duration / 60.0).round(1)

    return summarize_helper(
                              start_time,
                              duration_in_seconds,
                              duration_in_minutes,
                              duration_in_hours,
                              summary
                           )
  end # summarize

  def summarize_helper(
                        start_time,
                        duration_in_seconds,
                        duration_in_minutes,
                        duration_in_hours,
                        summary
                      )
    [
      start_time.strftime("%m/%d/%Y"),
      summary.commit_count,
      summary.pivotal_stories.count,
      duration_in_minutes,
      duration_in_hours,
      summary.author.name,
      summary.author.email,
      project_name,
      summary.message,
      summary.pivotal_stories.map(&:inspect).join('; '),
      start_time.strftime("%W").to_i,
      start_time.strftime("%Y").to_i
    ]
  end # summarize_helper

  def roll_up_to_days(commit, index)
    # Get the appropriate worklog
    author_date = commit.author_date.to_date

    #puts "DEBUG: Reading #{commit} #{author_date} from #{commit.author.email}"
    daylog = get_or_create_new_daylog(author_date)
    @worklog[author_date] = process_day_log(commit, index, daylog)
  end # roll_up_to_days

  def get_or_create_new_daylog(author_date)
    if @worklog[author_date]
      return @worklog[author_date]
    else
      return OpenStruct.new(
                      :date => author_date,
                      :duration => 0,
                      :commit_count => 0,
                      :pivotal_stories => Set.new
                    )
    end # if
  end # daylog

  def pivotal_ids(text)
    ::PivotalIdsExtractor.new(text).stories
  end

  def process_day_log(commit, index, daylog)
    #puts "DEBUG: Processing #{commit} - #{commit.author}"
    daylog.author = commit.author
    daylog.message = "#{daylog.message} --- #{commit.message}"
    daylog.duration = daylog.duration + calc_duration_in_minutes(@commits, index)

    # The git commit count
    daylog.commit_count += 1

    # Pivotal Stories
    stories = pivotal_ids(commit.message)
    if stories
      # It's a set, so each story only gets added once per day
      stories.each do |sid|
        daylog.pivotal_stories << sid
      end # each
    end # if stories

    return daylog
  end # process_day_log

  # Calculate the duration of work in minutes
  def calc_duration_in_minutes(log_entries, index)
    if index > 1
      # Compute the time between this and this previous entry
      return compute_commit_time_duration(log_entries[index], log_entries[index - 1])
    else
      # This is the first commit in the log
      return @options[:initial_effort_mins].to_f
    end
    return duration
  end # calc_duration_in_minutes

  def compute_commit_time_duration(commit, previous_commit)
    # Default duration in Ruby is in seconds, so lets make it minutes
    duration = (commit.author_date - previous_commit.author_date) / 60.0

    #initial_effort_mins: 30, session_duration_hrs: 3, max_commits: 1000
    if duration > @options[:session_duration_hrs].to_f * 60.0
      # first commit in this session
      duration = @options[:initial_effort_mins].to_f
    elsif duration < 0
      # probably a merge.
      duration = @options[:merge_effort_mins].to_f
    end

    return duration.to_f
  end # compute_commit_time_duration

  def project_name
    @options[:project]
  end

  def date_in_filter_range(date_to_check)
    if @options[:filter_by_year] and date_to_check
      date_to_check.strftime("%Y").to_i == @options[:filter_by_year]
    else
      true
    end
  end

end # class