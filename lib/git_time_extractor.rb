#
# Extract Reasonable Developer Time Records from a GIT Repository's Commit Log
#
# This is inspired by a RAKE task publicly posted by Sharad at
# http://www.tatvartha.com/2010/01/generating-time-entry-from-git-log/.
# However, it has been adapted to run without Rails from the command line.
#
# Portions (C) 2014 Rietta Inc. and licensed under the terms of the BSD license.
#
class GitTimeExtractor
  VERSION = '0.2.3'

  require 'autoload'
  require 'set'

  attr_accessor :options, :summary, :authors

  def initialize( opts = {
                          project: "Untitled",
                          path_to_repo: "./",
                          output_file: "-",
                          initial_effort_mins: 30,
                          merge_effort_mins: 30,
                          session_duration_hrs: 3,
                          max_commits: 1000
                        } )
    @options = opts
    @authors = Hash.new
  end

  def path_to_git_repo
    options[:path_to_repo]
  end

  def path_to_output_file
    options[:output_file]
  end

  def project_name
    options[:project]
  end

  def load_git_log_entries(path_to_git_repo)
    # Open the GIT Repository for Reading
    logger = Logger.new(STDOUT)
    logger.level = Logger::WARN
    g = Git.open(path_to_git_repo, :log => logger)
    logs = g.log(@options[:max_commits])
    return logs.entries.reverse
  end

  def scan_log_entries(log_entries)
    worklog = Hash.new
    # Go through the GIT commit records and construct the time
    log_entries.each_with_index do |commit, index|
      author_date = commit.author_date.to_date

      if worklog[author_date]
        daylog = worklog[author_date]
      else
        daylog = OpenStruct.new(
                                  :date => author_date,
                                  :duration => 0,
                                  :commit_count => 0,
                                  :pivotal_stories => Set.new
                                )
      end # if

      daylog.author = commit.author
      daylog.message = "#{daylog.message} --- #{commit.message}"
      daylog.duration = daylog.duration + calc_duration_in_minutes(log_entries, index)

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

      puts "Reading #{author_date} from #{commit.author.email}"
      worklog[author_date] = daylog
    end # log_entries.each_with_index
    return worklog
  end # scan_log_entries

  #
  # Go through the GIT commit log, to compute the elapsed working time of each committing developer, based
  # on a few assumptions:
  #
  # (1) A series of commits within a 3 hour window are part of the same development session
  # (2) A single commit (or the first commit of the session) is considered to represent 30 minutes of work time
  # (3) The more frequent a developer commits to the repository while working, the more accurate the time report will be
  #
  #
  def process_git_log_into_time
    rows = Array.new

    log_entries = load_git_log_entries(path_to_git_repo)
    worklog = scan_log_entries(log_entries)

    # Print the header row for the CSV
    rows << header_row_template()

    # Go through the work log
    worklog.keys.sort.each do |date|
        summary = worklog[date]
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

        rows << row
    end # worklog each

    @summary = rows
    rows
  end # process_git_log_into_time

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

  def say_hi
    "hi"
  end


  def pivotal_ids(text)
    ::PivotalIdsExtractor.new(text).stories
  end

  #####################################
  private

  def header_row_template
    [
      'Date',
      'Git Commits Count',
      'Pivotal Stories Count',
      'Minutes',
      'Hours',
      'Person',
      'Email',
      'Project',
      'Notes',
      'Pivotal Stories',
      'Week Number',
      'Year'
    ]
  end # header_row_template

end # class GitTimeExtractor
