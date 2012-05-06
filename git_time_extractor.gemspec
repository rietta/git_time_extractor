Gem::Specification.new do |s|
  s.license = "BSD"
  s.name = %q{git_time_extractor}
  s.version = "0.2.0"
  s.authors = ["Frank Rietta"]
  s.email = "products@rietta.com"
  s.summary = "Reasonable developer time log extractor that uses a GIT repository's commit log history."
  s.description = "Compute the estimated time spent by developers working on code within a GIT respository. Useful for verifying developer timesheets and for tax purposes."
  s.homepage = "https://github.com/rietta/git_time_extractor"
  s.files = ["bin/git_time_extractor", "README.txt", "History.txt"] + Dir["lib/**/*"]
  s.bindir = "bin"
  s.executables = ["git_time_extractor"]
  s.add_dependency "git"
  s.add_dependency "logger"
end