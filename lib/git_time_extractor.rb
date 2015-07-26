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
  VERSION = '0.3.2'

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
    @authors_hash = Hash.new
    @authors      = Array.new
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

  # Scan through the commit log entries and split into each author's accounting
  def distribute_entries_to_authors(log_entries)
    # Go through the GIT commit records and construct the time
    log_entries.each_with_index do |commit, index|
      key = commit.author.email
       if @authors_hash[key].nil?
         @authors_hash[key] = Author.new(@options)
       end
       @authors_hash[key].add_commit(commit)
    end # log_entries.each_with_index

    if @authors_hash
      @authors_hash.each do |key, value|
        if value
          value.tabulate_days
          @authors << value
          #puts "DEBUG: Looking at #{key}, #{value}, with #{value.rows.count} commits"
        end
      end
    end

    #puts "DEBUG: #{@authors.count} authors"

    return @authors
  end # distribute_entries_to_authors

  def prepare_rows_for_csv
    rows = Array.new
    rows << header_row_template()
    @authors.each do |author|
      author.rows.each do |author_row|
        rows << author_row
      end
    end
    return rows
  end

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
    distribute_entries_to_authors( load_git_log_entries( path_to_git_repo ) )
    return prepare_rows_for_csv
  end # process_git_log_into_time


  def prepare_rows_for_summary_csv
    rows = Array.new
    rows << summary_header_row_template()
    commits = 0
    hours = 0
    authors = Array.new
    @authors.each do |author|
      commits += author.total_commits()
      hours += author.total_working_hours()
      authors << author.commits[0].author.name + " (" + author.commits[0].author.email + ")"
    end
    rows << [
      commits,
      hours,
      authors.join(";")
    ]
    return rows
  end

  #
  # create a summary of the computed times
  #
  def process_git_log_into_summary
    distribute_entries_to_authors( load_git_log_entries( path_to_git_repo ) )
    return prepare_rows_for_summary_csv
  end # process_git_log_into_time


  def prepare_rows_for_author_summary_csv
    rows = Array.new
    rows << author_summary_header_row_template()
    commits = 0
    hours = 0
    authors = Array.new
    @authors.each do |author|
      rows << [
        author.total_commits(),
        author.total_working_hours(),
        author.commits[0].author.name,
        author.commits[0].author.email,
      ]
    end
    return rows
  end

  #
  # create a summary per author
  #
  def process_git_log_into_author_summary
    distribute_entries_to_authors( load_git_log_entries( path_to_git_repo ) )
    return prepare_rows_for_author_summary_csv
  end # process_git_log_into_time

  def process
    if options[:project_total]
      process_git_log_into_summary
    elsif options[:compact]
      process_git_log_into_author_summary
    else
      process_git_log_into_time
    end
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

  def author_summary_header_row_template
    [
      'Total Git Commits Count',
      'Total Hours',
      'Person',
      'Email',
      # 'From Date',
      # 'To Date',
    ]
  end # summary_header_row_template

  def summary_header_row_template
    [
      # 'From Date',
      # 'To Date',
      'Total Git Commits Count',
      'Total Hours',
      'Collaborators',
    ]
  end # summary_header_row_template

end # class GitTimeExtractor
