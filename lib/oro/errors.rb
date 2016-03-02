# Oro error classes
class OroError < Exception
  def initialize(msg)
    @msg = msg
  end

  def message
    "Error: #{@msg}"
  end
end

class PartInstantiationError < OroError; end

class MatchlessLengthWordError < OroError; end

class NoMatchingListError < OroError; end

class ListIsNonContiguousError < OroError; end
