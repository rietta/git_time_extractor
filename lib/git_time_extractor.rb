#
# Extract Reasonable Developer Time Records from a GIT Repository's Commit Log
#
# This is inspired by a RAKE task publicly posted by Sharad at 
# http://www.tatvartha.com/2010/01/generating-time-entry-from-git-log/. 
# However, it has been adapted to run without Rails from the command line.
#
# Portions (C) 2012 Rietta Inc. and licensed under the terms of the BSD license.
#
class GitTimeExtractor
  VERSION = '0.2.1'
  
  require 'rubygems'
  require 'ostruct'
  require 'logger'
  require 'git'
  require 'csv'

  #
  # Go through the GIT commit log, to compute the elapsed working time of each committing developer, based
  # on a few assumptions:
  #
  # (1) A series of commits within a 3 hour window are part of the same development session
  # (2) A single commit (or the first commit of the session) is considered to represent 30 minutes of work time
  # (3) The more frequent a developer commits to the repository while working, the more accurate the time report will be
  #
  #
  def self.process_git_log_into_time(path_to_git_repo = "./", path_to_output_file = "-", project_name = "")

    if "-" != path_to_output_file
      raise "Output path not yet implemented. Use a Unix pipe to write to your desired file. For example: git_time_extractor ./ > my_result.csv\n" 
    end 
    
    # Open the GIT Repository for Reading
    logger = Logger.new(STDOUT)
    logger.level = Logger::WARN
    g = Git.open(path_to_git_repo, :log => logger)
    logs = g.log(1000)
    log_entries = logs.entries.reverse
    worklog = {}

    # Go through the GIT commit records and construct the time
    log_entries.each_with_index do |commit, index|
      author_date = commit.author_date.to_date
      daylog = worklog[author_date] || OpenStruct.new(:date => author_date, :duration => 0)
      daylog.author = commit.author
      daylog.message = "#{daylog.message} --- #{commit.message}"
      daylog.duration = daylog.duration + calc_duration_in_minutes(log_entries, index)
      worklog[author_date] = daylog
    end # log_entries.each_with_index

    # Print the header row for the CSV
    puts [
        'Date',
        'Minutes',
        'Hours',
        'Person',
        'Email',
        'Project',
        'Notes',
        'Week Number',
        'Year'
        ].to_csv

    # Go through the work log  
    worklog.keys.sort.each do |date|

        start_time = DateTime.parse(date.to_s)
        duration_in_seconds = (worklog[date].duration.to_f * 60.0).round(0)
        duration_in_minutes = worklog[date].duration.to_i
        duration_in_hours = (worklog[date].duration / 60.0).round(1)

        stop_time = start_time + duration_in_seconds
        row = [
              start_time.strftime("%m/%d/%Y"), 
              duration_in_minutes,
              duration_in_hours,
              worklog[date].author.name,
              worklog[date].author.email,
              project_name,
              worklog[date].message,
              start_time.strftime("%W").to_i,
              start_time.strftime("%Y").to_i]
        puts row.to_csv
    end # worklog each

  end # process_git_log_into_time

  # Calculate the duration of work in minutes
  def self.calc_duration_in_minutes(log_entries, index)
    commit = log_entries[index]
    if index > 1
      previous_commit = log_entries[index-1]
      # Default duration in Ruby is in seconds
      duration = commit.author_date - previous_commit.author_date
      
      # ASSUMPTION: if the gap between 2 commits is more than 3 hours, reduce it to 1/2 hour
      # Also, if the time is negative then this is usually a merge operation.  Assume the developer spent
      # 30 minutes reviewing it
      duration = 30 * 60 if duration < 0 || duration > 3 * 3600
    else
      # ASSUMPTION: first commit took 1/2 hour
      duration = 30 * 60
    end
    return duration.to_f / 60.0
  end # calc_duration_in_minutes

  def self.say_hi
    "hi"
  end
end # class GitTimeExtractor
