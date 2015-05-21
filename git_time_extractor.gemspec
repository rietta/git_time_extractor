Gem::Specification.new do |s|
  s.required_ruby_version = '>= 1.9.3'
  s.license = "BSD"
  s.name = %q{git_time_extractor}
  s.version = "0.3.2"
  s.authors = ["Frank Rietta"]
  s.email = "hello@rietta.com"
  s.summary = "Analyzes Git repository commit logs to compute developer working hours, weekly activity, and to detect death marches in software development."
  s.description = "Analyzes Git repository commit log to compute developer working hours, weekly activity, and to detect death marches in software development. It computes the timing statistics based on the timestamps of each commit and the intervals between them. Useful for verifying developer time sheets and for tax purposes and it supports filtering for a specific tax year. See https://github.com/rietta/git_time_extractor/wiki."
  s.homepage = "https://github.com/rietta/git_time_extractor"
  s.files = ["bin/git_time_extractor", "readme.md", "History.txt"] + Dir["lib/**/*"]
  s.bindir = "bin"
  s.executables = ["git_time_extractor"]
  s.add_dependency "git", "~>1.2"
  s.add_dependency "logger", "~>1.2"
end