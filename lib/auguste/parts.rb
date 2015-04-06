class Part
  def self.list_location ; @list_location end
  def self.list_location=(location) ; @list_location = location end
  def self.count ; list.size end # list is memoized and via class method added by AssemblyLine#instantiate
  def self.shortest ; @shortest ||= list.empty? ? 0 : list.min{|a,b| a.length <=> b.length}.length end
  def self.longest ; @longest ||= list.empty? ? 0 : list.max{|a,b| a.length <=> b.length}.length end
  def self.middle ; (self.shortest + self.longest) / 2 end
  def self.distinct? ; list.size == list.uniq.size ? true : false end
  def self.get_one ; list.sample end  
  def self.descendants ; ObjectSpace.each_object(Class).select{ |klass| klass < self } end
  def self.to_s ; "List #{self.name} > count:#{count}, shortest:#{shortest}, longest:#{longest}, middle:#{middle}, distinct:#{distinct?}, get one:'#{get_one}'" end
end

  class SingleCharacterPart < Part
    def self.get(size, config={})
      result = []
      size.times{ result << get_one}
      result.join
    end
  end

  class Word < Part
    LEET = { 'a'=>['@'], 'b'=>['|3'], 'd'=>['|)'], 'e'=>['3'], 'f'=>['ph'], 'i'=>['|'], 'k'=>['|<'], 'l'=>['|_'], 'o'=>['0'], 'p'=>['|*'], 's'=>['$','5'], 'w'=>["'//"]}
    def self.to_s ; super + ", contiguous:#{contiguous?}" + (absences.empty? ? '' : ", absences:#{absences}") end
    def self.contiguous? ; absences.empty? end
    def self.absences
      length_exists = Proc.new{|length| list.select{|w| w.length == length}.empty? ? false : true}
      lengths = [] ; (self.shortest..self.longest).each{|len| exists = length_exists.call(len) ; lengths << len if not exists}
      lengths
    end

    def self.get(size, config={})
      raise MatchlessLengthWordError.new("Matchless length of #{size} requested from:\n#{to_s}") if size < self.shortest or size > self.longest

      get_proc, attempt = Proc.new{ get_one } , "" # FIXME The performance benefit of refactoring to use Array#reject, or possibly reject!, should be tested.
      until attempt.length == size do
        attempt = get_proc.call
      end

      if config[:capitalize]
        attempt.capitalize!
      end

      if config[:capitalize_random]
        temp = attempt.chars ; temp[rand(temp.length)].upcase! ; attempt = temp.join
      end

      if config[:l33t]
        leetables = {}
        LEET.keys.each{|l| matches = (0...attempt.length).find_all{|i| attempt[i,1] == l} ; leetables[l] = matches unless matches.empty?} # An index histogram of matching leetables; ex: {"a"=>[9], "e"=>[0, 6], "i"=>[8]}

        unless leetables.empty?
          leeted = leetables.to_a.sample(1).flatten.first # Get a random key from the histogram
          attempt.sub!(leeted, LEET[leeted][rand(LEET[leeted].length)]) # Change to gsub to replace all matches
        end
      end

      attempt
    end

  end
