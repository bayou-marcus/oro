require_relative 'parts'
require_relative 'helpers'
require_relative 'settings'
require_relative 'errors'
require_relative 'settings_parser'

# A class epresenting a complete password
class Password
  include SettingsAccessors
  attr_accessor :settings
  attr_reader :virgin_settings

  # Class methods

  # Singleton helper returning classes required by password
  def self.components_for(settings)
    parts = []
    settings.plan.each { |part| parts << Object.const_get(part[0]) }
    parts.uniq
  end

  def self.installed_part_classes
    Part.descendants
  end

  def self.installed_parts
    Part.descendants.map(&:name)
  end

  def self.installed_part_switches
    switches = {}
    installed_parts.each do |part|
      part.downcase.chars.each { |char| switches.keys.include?(char) ? next : (switches[char] = part; break) }
    end
    switches
  end

  def self.installed_summary
    count = 0
    Password.installed_part_classes.each do |klass|
      klass.listify
      count += klass.count
      puts klass.to_s
    end
    puts "Total list members: #{count}"
  end

  # Instance methods

  def initialize(clio = '')
    # Parse clio
    @settings = SettingsParser.parse(clio)

    # Save virgin parsed settings
    @virgin_settings = @settings.dup

    # Use saved preferences plan, then defaults plan, if no plan provided in clio
    @settings.plan = (Preferences.instance.plan.empty? ? Defaults.instance.plan : Preferences.instance.plan) if @settings.plan.empty?

    # Settings merged with Preferences, that merged with Defaults
    @settings.config = Defaults.instance.config.merge(Preferences.instance.config.merge(@settings.config))

    # Assign correct dictionary-specified class to Word parts, removing ambiguous 'Word' parts left by SettingsParser
    @settings.plan.each { |part| part[0] = @settings.config[:dictionary] if part[0] == 'Word' }

    # Check for NoMatchingListError
    # FIXME: fix
    # raise NoMatchingListError.new("No matching dictionary for '#{@settings.config[:dictionary]}'") unless Password.installed_word_parts.include?(@settings.config[:dictionary])

    # Add lists for required part classes only, check for non-contiguous lists
    Password.components_for(@settings).each do |klass|
      klass.listify
      fail ListIsNonContiguousError, "Dictionary #{klass.name} is noncontiguous and requires at least one entry for each range member\n#{klass.to_s}" unless klass.contiguous?
    end
  end

  def length
    length = 0
    @settings.plan.each { |part| length += part[1].nil? ? Object.const_get(part[0]).middle : part[1] }
    @settings.config.key?(:l33t) && @settings.config[:l33t] == true ? "#{length}+" : length.to_s # Precision is out the window with l33t; && likely uneeded
  end

  def result
    current_password = []

    @settings.plan.each do |plan_part|
      part_klass = self.class.const_get(plan_part[0]) # The part descriptor from auguste settings
      plan_part[1] = part_klass.middle if plan_part[1].nil? # Potentially optimize: this causes full list sorts for shortest & longest
      current_password << part_klass.get(plan_part[1], @settings.config) # Passing config, Parts don't currently rely on the Preferences singleton
    end

    current_password.shuffle! if @settings.config[:shuffle]
    current_password.join
  end
end
