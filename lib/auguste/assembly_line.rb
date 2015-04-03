require 'yaml'
require 'json'
require 'benchmark'
require_relative 'error'
require_relative 'settings'

class AssemblyLine

  def self.instantiator(klass_name, superklass, list) # list is an array or filepath (string) FIXME rm per below?
    klass = Object.const_set(klass_name, Class.new(superklass))
    list = YAML.load_file(list) if list.is_a?(String) # FIXME When is this used, when is list a String, not an array?
    klass.instance_exec(list) do |l| # instance_exec (vs. instance_eval) allows passing params
      define_singleton_method('list'){ @list ||= l } # define_singleton_method adds the class method
    end
    warn(klass.to_s) if $VERBOSE
  end

  private_class_method :instantiator

  def self.dictionary_files(dicts) # FIXME Should all the lists be stored in /dictionaries and treated the same?  Would probably need to add class metadata.
    dictionary_files = {}
    Dir.glob(File.join(File.dirname(__FILE__), 'dictionaries', '*.yml')) do |dictionary|
      dictionary_files[(File.basename(dictionary, '.*').gsub(/\/(.?)/){'::' + $1.upcase}.gsub(/(^|_|-)(.)/){$2.upcase})] = dictionary # Ie: Camelize
    end    
    dicts == :all ? dictionary_files : dictionary_files.keep_if{|k,v| k == dicts}
  end

  def self.instantiate_part_klasses(dicts)
    arg_sets = []
    arg_sets << ['Number', SingleCharacterPart, ('0'..'9').to_a]
    arg_sets << ['Punctuation', SingleCharacterPart, %w(~ ` ! @ # $ % ^ & * ( ) _ - + = { } [ ] | / : ; ' < > , . ?)] # Bad: \ "
    dictionary_files(dicts).each_pair{|k,v| arg_sets << [k, Word, YAML.load_file(v)]}
    arg_sets.each{|args| instantiator(args[0], args[1], args[2]) }
  end

  def self.lists
    SingleCharacterPart.descendants.concat(Word.descendants).each{|k|puts k.to_s}
  end

	def run
    raise NoMatchingListError.new("No matching dictionary for '#{Options.instance.config[:dictionary]}'") unless AssemblyLine.dictionary_files(:all).has_key?(Options.instance.config[:dictionary])

    dict_klass = self.class.const_get(Options.instance.config[:dictionary])
    raise ListIsNonContiguousError.new("Dictionary #{Options.instance.config[:dictionary]} is noncontiguous and requires at least one entry for each range member\n#{dict_klass.to_s}") unless dict_klass.contiguous?

    passwords = []
    time = Benchmark.measure do
      (1..Options.instance.config[:iterations]).each{ passwords << Password.new.pw }
    end

    warn("Time to generate #{Options.instance.config[:iterations]} passwords: #{time.real}, #{time.real / Options.instance.config[:iterations]} per password") if $VERBOSE

    # We are done
    case Options.instance.config[:format]
    when 'json'
      passwords.to_json
    when 'yaml', 'yml'
      passwords.to_yaml
    when 'string'
      passwords.join(Options.instance.config[:separator]).strip
    end
	end

end
