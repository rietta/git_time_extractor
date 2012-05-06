require "test/unit"
require "git_time_extractor"

# TODO: Test cases are needed.  It is not immediately clear how to best build a test suite.
# Supposedly if a GIT repository was distributed within this Gem, it could be used to verify
# that this gem can write out a log.
#
class TestGitTimeExtractor < Test::Unit::TestCase
  def test_sanity
    assert_equal "hi", GitTimeExtractor.say_hi  
  end
end
