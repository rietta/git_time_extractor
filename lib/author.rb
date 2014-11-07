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

  # Then the tabulation is called after the commits are added into this author's list
  def tabulate_days
    @commits.each_with_index do |commit, index|
       roll_up_to_days commit, index
    end

    # Go through the work log
    @worklog.keys.sort.each do |date|
        summary = @worklog[date]
        start_time = DateTime.parse(date.to_s)
        duration_in_seconds = (summary.duration.to_f * 60.0).round(0)
        duration_in_minutes = summary.duration.to_i
        duration_in_hours   = (summary.duration / 60.0).round(1)

        row = [
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
        #puts "DEBUG: #{row}"
        @rows << row
    end # worklog each
  end # tabulate_days

  def roll_up_to_days(commit, index)
    # Get the appropriate worklog
    author_date = commit.author_date.to_date

    #puts "DEBUG: Reading #{commit} #{author_date} from #{commit.author.email}"
    daylog = get_or_create_new_daylog(author_date)
    @worklog[author_date] = process_day_log(commit, index, daylog)
  end # sample

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
    commit = log_entries[index]
    if index > 1
      previous_commit = log_entries[index-1]
      # Default duration in Ruby is in seconds, so lets make it minutes
      duration = (commit.author_date - previous_commit.author_date) / 60

      #initial_effort_mins: 30, session_duration_hrs: 3, max_commits: 1000
      if duration > @options[:session_duration_hrs].to_f * 60
        # first commit in this session
        duration = @options[:initial_effort_mins].to_f
      elsif duration < 0
        # probably a merge.
        duration = @options[:merge_effort_mins].to_f
      end
    else
      # first commit ever
      duration = @options[:initial_effort_mins].to_f
    end
    return duration.to_f
  end # calc_duration_in_minutes

  def project_name
    @options[:project]
  end

end # class