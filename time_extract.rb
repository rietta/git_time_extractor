#!/usr/bin/env ruby
# Rietta GIT to TimeLog Extractor
# Based on work by http://www.tatvartha.com/2010/01/generating-time-entry-from-git-log/

require 'rubygems'
require 'ostruct'
require 'logger'
require 'git'
require 'csv'

#task :timelog => [:environment] do
# process_git_log_into_time(Rails.root.to_s)
#end

def process_git_log_into_time(path_to_git_repo = "./", path_to_output_file = "-")
  logger = Logger.new(STDOUT)
  logger.level = Logger::WARN
  g = Git.open(path_to_git_repo, :log => logger)
  logs = g.log(1000)
  log_entries = logs.entries.reverse
  worklog = {}
  log_entries.each_with_index do |commit, index|
    author_date = commit.author_date.to_date
    daylog = worklog[author_date] || OpenStruct.new(:date => author_date, :duration => 0)
    daylog.author = commit.author
    daylog.message = "#{daylog.message} --- #{commit.message}"
    daylog.duration = daylog.duration + calc_duration_in_minutes(log_entries, index)
    worklog[author_date] = daylog
  end
  
  #if "-" == path_to_output_file
  #  csv = CSV  # Standard out
  #else
  #  csv = File.open(path_to_output_file, "w") 
  #end
  puts [
      #'Original Timestamp', 
      'Date', 
      #'Start', 
      #'End', 
      'Minutes', 'Hours', 'Person', 'Email', 'Notes', 'Week Number', 'Year'].to_csv
  
      
  # Go through the work log  
  worklog.keys.sort.each do |date|
      #timestamp = date.to_s(:db)
      #timestamp = date
      
      start_time = DateTime.parse(date.to_s)
      duration_in_seconds = (worklog[date].duration.to_f * 60.0).round(0)
      duration_in_minutes = worklog[date].duration.to_i
      duration_in_hours = (worklog[date].duration / 60.0).round(1)
      
      stop_time = start_time + duration_in_seconds
      #puts "#{timestamp} #{duration_in_hours}"
      row = [
            #date.to_s, 
            start_time.strftime("%m/%d/%Y"), 
            #start_time.strftime("%H:%M"),
            #stop_time.strftime("%H:%M"),
            duration_in_minutes,
            duration_in_hours,
            worklog[date].author.name,
            worklog[date].author.email,
            worklog[date].message,
            start_time.strftime("%W").to_i,
            start_time.strftime("%Y").to_i]
      puts row.to_csv
  end # worklog each

end # process_git_log_into_time
 
def calc_duration_in_minutes(log_entries, index)
  commit = log_entries[index]
  if index > 1
    previous_commit = log_entries[index-1]
    
    # Default duration in Ruby is in seconds
    duration = commit.author_date - previous_commit.author_date
    # ASSUMPTION: if the gap between 2 commits is more than 3 hours, reduce it to 1/2 hour
    duration = 30 * 60 if duration > 3 * 3600
  else
    # ASSUMPTION: first commit took 1/2 hour
    duration = 30 * 60
  end
  
  return duration.to_f / 60.0
end # calc_duration


####################################
## Command Line UI
####################################

#puts "\n# Arguments #{ARGV.length}\n"
if ARGV.empty?
  output_file = "-"
  path_to_repo = Dir.pwd
elsif ARGV.length == 2
  output_file = ARGV.pop
  path_to_repo = ARGV.pop
elsif ARGV.length == 1
  output_file = "-"
  path_to_repo = ARGV.pop
else
  puts "Usage: time_extract PATH_TO_REPO [OUTPUT_FILE]"
  exit 0
end

#path_to_repo = File.expand_path(File.dirname(path_to_repo)) if nil != path_to_repo && "" != path_to_repo
#puts "\n\nGit Repo Path: #{path_to_repo}\nOutput: #{output_file}\n"
process_git_log_into_time(path_to_repo, output_file)

