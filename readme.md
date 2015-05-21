[![Gem Version](https://badge.fury.io/rb/git_time_extractor.png)](http://badge.fury.io/rb/git_time_extractor)
[![Code Climate](https://codeclimate.com/github/rietta/git_time_extractor/badges/gpa.svg)](https://codeclimate.com/github/rietta/git_time_extractor)

# Extract Reasonable Time Records from a Git Repository

This tool goes through a GIT repository's commit log and prints a CSV dump of per developer, per day working time based on a few assumptions:

 - A series of commits within a 3 hour window are part of the same development session
 - A single commit (or the first commit of the session) is considered to represent 30 minutes of work time
 - The more frequent a developer commits to the repository while working, the more accurate the time report will be

This script is based on previous code published publicly by *Sharad* at http://www.tatvartha.com/2010/01/generating-time-entry-from-git-log/. However, it has been adapted to run without Rails from the command line. The portions of the code written by Rietta are licensed under the terms of the BSD license (see section 3 below).

## 0. Installing from Ruby Gems

To quickly get started, just run:
`gem install git_time_extractor`

You can see it at https://rubygems.org/gems/git_time_extractor.

## 1. Running

### Usage

Command line configurable options are supported!

```
Usage: git_time_extractor [options]
    -p, --project PROJECT
    -i, --repo-path REPOPATH
    -o, --out OUTPUT_CSV
    -c, --max-commits MAX_COMMITS    Maximum number of commits to read from Git. Default: 10000
    -y, --year YEAR                  Filter for commits in a given four digit year, such as 2015 or 2014. Default: Records for all years.
    -e INITIAL_EFFORT,               Initial Effort before each commit, in minutes. Default: 30
        --initial-effort
    -m, --merge-effort MERGE_EFFORT  Effort spent merging, in minutes. Default: 30
    -s SESSION_DURATION,             Session duration, in hours. Default: 3
        --session-duration
        --project-total              Project commits and time rolled into a single summary line. The field set is total git commit count, total hours, and a list of collaborators.
        --compact                    Compact mode that lists only total git commit count, total hours, person, email.
```
### Most basic usage

- `cd /path/to/your/repository`
- `git_time_extractor > time_log.csv`

### Filtering for a specific year
One basic usage of `git_time_extractor` is to tabulated time spent on a project in a particular year. Using a year filter is a way to restrict the output to just records for days in a given calendar year.

`git_time_extractor -y 2014 -i ~/Projects/GreatOpenSourceWork`

Will scan the git repo in `~/Projects/GreatOpenSourceWork`, reporting only on the days between January 1, 2014, and December 31, 2015.
## 2. Analysis

Once the you have used Git Time Extractor to prepare a CSV file, you can perform a lot of different analysis operations using a spreadsheet.  See the [examples spreadsheets](examples/) for some ideas.

## 3. License Terms (BSD License)

&copy; 2012-2015 Rietta, Inc, and contributors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## 4. Further reading / other projects

- [Kimmo Brunfeldt](https://github.com/kimmobrunfeldt) has written [git-hours](
https://github.com/kimmobrunfeldt/git-hours), a NodeJS-based clone that was inspired by this `git_time_extractor`.
- [Ad van der Veer](https://github.com/advanderveer) is working on [Timeglass](https://github.com/timeglass/glass) in the Go programming language. Unlike `git_time_extractor` and `git-hours`, both of which are built around analyzing past activity, his approach runs a timer in real time during the developer's work and annotates git commits with the time data.

## 5. What users say

[Jason Fieldman: Theseus 3D (2014)](http://www.fieldman.org/theseus-3d/)
> git_time_extractor says that there is approximately 120 hours of development time on my repo, from September 19 through October 22. Pretty much all grouped on weekends (and our school’s extended 5-day break). The tool overestimates a bit because it does not compensate for meals or mid-session breaks, but it’s relatively close. So let’s say it’s closer to 90-100 hours – not bad to complete the game, including research and dealing with SceneKit foibles along the way.