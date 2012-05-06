= git_time_extractor

Project Wiki: https://github.com/rietta/git_time_extractor/wiki

== DESCRIPTION:

EXTRACT REASONABLE TIME RECORDS FROM A GIT REPOSITORY

git_time_extractor is a free tool that goes through a GIT, the popular revision control system, repository's commit log and produces a Comma Seperated Values (CSV) file that indicates the time spent by each developer, per day. 

The working time estimates are based on three assumptions:

    1. A series of commits within a 3 hour window are part of the same development session
    2. A single commit (or the first commit of the session) is considered to represent 30 minutes of work time
    3. The more frequent a developer commits to the repository while working, the more accurate the time report will be

This script is based on previous code published publicly by Sharad at http://www.tatvartha.com/2010/01/generating-time-entry-from-git-log/. However, it has been adapted to run without Rails from the command line. The portions of the code written by Rietta are licensed under the terms of the BSD license (see section 3 below).

git_time_extractor is useful for software development companies that want to discover the approximate time spent by developers on particular projects based on real data in the GIT revision control system. This is useful for managers, accountants, and for those who need to back up records for tax purposes.

For example, in the United States there is a Research & Development (R&D) tax credit available for companies who build or improve software for certain purposes.  To claim this credit requires certain types of records.  Check with your accountant to see if the results from this program is appropriate in your particular situation.  You can learn more information about this particular credit at http://www.irs.gov/businesses/article/0,,id=156366,00.html.

== BENEFITS:

	* Compute time records based on the timestamps of each code commit by each developer
	* Compare these results with other time-sheets or metrics to measure the effectiveness of your team members
	* Save money on taxes by producing documents required by your accountant to properly apply for certain tax credits
	* It's a Free Open Source Tool
	
== FEATURES:

	* Easy command-line operation
	* Reads from a local GIT branch in the current directory
	* Writes to a CSV-file that is compatible with Microsoft Excel, OpenOffice Calc, or Google Docs
	
== SYNOPSIS:

  	cd /path/to/your/repository
  	git_time_extractor > time_log.csv

== REQUIREMENTS:

	The following GEMS are required as dependencies:
		* git
		* logger

== INSTALL:

	gem install git_time_extractor

== UNINSTALL:
	
	gem install git_time_extractor

== DEVELOPERS:

After checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

== LICENSE:

(The BSD License)

Copyright (c) 2012 Rietta Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
    
