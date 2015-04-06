require_relative 'parts'
require_relative 'helpers'
require_relative 'settings'
require_relative 'errors'
require_relative 'options_parser'

# FIXME This should be a functional and wholly self-contained class, where when you create an instance of it with no params, it gives you back a password (maybe based on random parts and lengths).  If you pass options, then it gives you one like you requested. That would mean all parts namespaced here. Once the instance variable(s) that save the plan are set, calling .pw will issue new passwords based on that plan.
class Password

  using Helpers
  include OptionsAccessors, Helpers
  attr_accessor :settings
  attr_reader :virgin_settings


  # Pseudo-"Password.initialize" which initializes list-less parts classes from all installed <list>.yml files, * at load time *
  begin
    Dir.glob(File.join(File.dirname(__FILE__), 'lists', '**', '*.yml')) do |list|
      klass_name = File.basename(list, '.yml').camelize
      superklass_name = File.dirname(list).split(File::SEPARATOR).pop
      instantiated = Object.const_set(klass_name, Class.new(Object.const_get(superklass_name)))
      instantiated.list_location = list
    end
  rescue PartInstantiationError => e
    puts e.message
  end # End part class initilization


  # Class methods

  # Singleton helper returning classes required by password 
  def self.components_for(settings)
    parts = [] ; settings.plan.each{|part| parts << Object.const_get(part[0])} ; parts.uniq
  end

  def self.listify_for(klass)
    list = YAML.load_file(klass.list_location)
    klass.instance_exec(list) do |l| # instance_exec (vs. instance_eval) allows passing params
      define_singleton_method('list'){ @list ||= l } # define_singleton_method adds the class method
    end
    warn(klass.to_s) if $VERBOSE
    klass.respond_to?(:list) ? true : false
  end

  def self.installed_part_classes ; SingleCharacterPart.descendants.concat(Word.descendants) end
  def self.installed_word_parts ; Word.descendants.map{|k|k.name} end
  def self.installed_summary
    count = 0
    Password.installed_part_classes.each{|klass| Password.listify_for(klass) ; count += klass.count ; puts klass.to_s}
    puts "Total list members: #{count}"
  end


  # Instance methods

  def initialize(clio=nil)
    # Parse clio
    @settings = OptionsParser.parse(clio)

    # Save virgin parsed settings
    @virgin_settings = @settings.dup

    # Use saved preference plan if no plan provided in clio
    @settings.plan = Preferences.instance.plan if @settings.plan.empty?

    # Merge default config with any options given
    @settings.config = Defaults.instance.config.merge(@settings.config)

    # Assign correct dictionary-specified class to Word parts, removing ambiguous 'Word' parts left by OptionsParser
    @settings.plan.each{|part| part[0] = @settings.config[:dictionary] if part[0] == 'Word'}

    # Check for NoMatchingListError
    raise NoMatchingListError.new("No matching dictionary for '#{password.config[:dictionary]}'") unless Password.installed_word_parts.include?(@settings.config[:dictionary])

    # Add lists for required part classes only
    Password.components_for(@settings).each{|klass| Password.listify_for(klass)}

    # Check for ListIsNonContiguousError
    raise ListIsNonContiguousError.new("Dictionary #{@settings.config[:dictionary]} is noncontiguous and requires at least one entry for each range member\n#{dict_klass.to_s}") unless Object.const_get(@settings.config[:dictionary]).contiguous?
  end

  def length
    length = 0
    @settings.plan.each{|part| length += part[1].nil? ? Object.const_get(part[0]).middle : part[1]}
    @settings.config.has_key?(:l33t) && @settings.config[:l33t] == true ? "#{length}+" : length.to_s # Precision is out the window with l33t; && likely uneeded
  end

  def result
    current_password = []

    for plan_part in @settings.plan do
      case plan_part[0]
      when 'Word'
        plan_part[0] = @settings.config[:dictionary]
        plan_part[1] = Object.const_get(@settings.config[:dictionary]).middle if plan_part[1].nil?
      when 'Number', 'Punctuation'
        plan_part[1] = 1 if plan_part[1].nil?
      end

      part_klass = self.class.const_get(plan_part[0]) # The part descriptor from auguste options
      current_password << part_klass.get(plan_part[1], @settings.config) # Passing config, Parts don't currently rely on the Preference singleton
    end

    current_password.shuffle! if @settings.config[:shuffle]
    current_password.join
  end

end
