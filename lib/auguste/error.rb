class AugusteError < Exception
  def initialize(msg) ; @msg = msg end
  def message ; "Error: #{@msg}" end
end

class MatchlessLengthWordError < AugusteError ; end

class NoMatchingListError < AugusteError ; end

class ListIsNonContiguousError < AugusteError ; end
