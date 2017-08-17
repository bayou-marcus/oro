# Class representing a password plan part, which map to installed part lists
class Part
  LEET = { 'a' => ['@'], 'b' => ['|3'], 'd' => ['|)'], 'e' => ['3'], 'f' => ['ph'], 'i' => ['|'], 'k' => ['|<'],
           'l' => ['|_'], 'o' => ['0'], 'p' => ['|*'], 's' => ['$', '5'], 'w' => ["'//"] }

  def self.list_location
    @list_location
  end

  def self.list_location=(location)
    @list_location = location
  end

  # instance_exec (vs. instance_eval) to pass params, define_singleton_method to add the class method
  def self.listify
    list = YAML.load_file(@list_location)
    instance_exec(list) { |l| define_singleton_method('list') { @list ||= l } }
    self.respond_to?(:list) ? true : false
  end

  def self.single_character_list?
    (shortest == 1 && longest == 1) ? true : false
  end

  def self.count
    list.size
  end

  def self.shortest
    @shortest ||= list.empty? ? 0 : list.min { |a, b| a.length <=> b.length }.length
  end

  def self.longest
    @longest ||= list.empty? ? 0 : list.max { |a, b| a.length <=> b.length }.length
  end

  def self.middle
    (shortest + longest) / 2
  end

  def self.distinct?
    list.size == list.uniq.size ? true : false
  end

  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  def self.contiguous?
    absences.empty?
  end

  def self.absences
    length_exists = proc { |length| list.select { |w| w.length == length }.empty? ? false : true }
    lengths = []
    (shortest..longest).each do |len|
      lengths << len if !length_exists.call(len)
    end
    lengths
  end

  def self.get_one
    list.sample
  end

  def self.get(size, config = {})
    single_character_list? ? get_for_single_character_part(size, config) : get_for_word_part(size, config)
  end

  def self.get_for_single_character_part(size, config)
    result = []
    size.times { result << get_one }
    result.first.capitalize! if config[:capitalize]
    result[rand(result.length)].upcase! if config[:capitalize_random]
    result.join
  end

  def self.get_for_word_part(size, config = {})
    fail MatchlessLengthWordError, "Matchless length of #{size} requested from:\n#{self}" if size < shortest || size > longest

    # FIXME: The performance benefit of refactoring to use Array#reject, or possibly reject!, should be tested.
    get_proc, attempt = proc { get_one }, ''

    until attempt.length == size do attempt = get_proc.call end

    attempt.capitalize! if config[:capitalize]

    if config[:capitalize_random]
      temp = attempt.chars
      temp[rand(temp.length)].upcase!
      attempt = temp.join
    end

    # An index histogram of matching leetables; ex: {"a"=>[9], "e"=>[0, 6], "i"=>[8]}
    if config[:l33t]
      leetables = {}
      LEET.keys.each do |l|
        matches = (0...attempt.length).find_all { |i| attempt[i, 1] == l }
        leetables[l] = matches unless matches.empty?
      end

      unless leetables.empty?
        leeted = leetables.to_a.sample(1).flatten.first # Get a random key from the histogram
        attempt.sub!(leeted, LEET[leeted][rand(LEET[leeted].length)]) # Change to gsub to replace all matches
      end
    end
    attempt
  end

  def self.to_s
    "List #{name} > count:#{count}, shortest:#{shortest}, longest:#{longest}, middle:#{middle}, distinct:#{distinct?}, get one:'#{get_one}', contiguous:#{contiguous?}" + (absences.empty? ? '' : ", absences:#{absences}")
  end
end

# Initialize list-less parts classes from all installed <list>.yml files, * at load time *
begin
  require_relative 'helpers'
  using Helpers

  PARTS_DIRECTORY = 'parts'

  Dir.glob(File.join(File.dirname(__FILE__), PARTS_DIRECTORY, '**', '*.yml')) do |list|
    klass_name = File.basename(list, '.yml').camelize
    instantiated = Object.const_set(klass_name, Class.new(Part)) # Creates subclasses of Part
    instantiated.list_location = list
  end

rescue PartInstantiationError => e
  puts e.message
end # End part class initilization
