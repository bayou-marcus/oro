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

  # Returns classes for all installed parts
  def self.installed_part_classes
    Part.descendants
  end

  # Returns string names for all installed parts
  def self.installed_parts
    Part.descendants.map(&:name)
  end

  # Returns a hash of "short" => "long" part identifiers
  def self.installed_part_switches
    switches = {} # FIXME: This apparently can't be memoized (?)
    installed_parts.each do |part|
      part.downcase.chars.each { |char| switches.key?(char) ? next : (switches[char] = part; break) }
    end
    switches
  end

  # Returns a help message for all installed parts
  def self.installed_parts_help
    help = []
    installed_part_switches.each_pair do |s, l|
      help << "    #{s}[n] #{l} part" # FIXME: There has to be a string format approach for making this match up.
    end
    help.join("\n")
  end

  # Returns a text list of metadata about all installed parts
  def self.installed_parts_summary
    count = 0
    Password.installed_part_classes.each do |klass|
      klass.listify
      count += klass.count
      puts klass.to_s
    end
    "Total list members: #{count}"
  end

  # Instance methods

  def initialize(clio = '')
    # Parse clio for Config and Actions
    @settings = SettingsParser.parse(clio)

    # Parse, manually, remaining non-switch plan parts
    clio.each do |part|
      match = (/\b([a-zA-Z]{1})([0-9]*)\b/).match(part)
      if match
        @settings.plan.push([Password.installed_part_switches[match[1]], match[2] == '' ? nil : match[2].to_i]) # nil behaves better with --prefs
        raise NoMatchingListError.new("No matching dictionary for '#{match[1]}'") unless Password.installed_part_switches.keys.include?(match[1])
      end
    end

    # Add help for installed parts if needed
    @settings.actions[:help].gsub!(/INSTALLED_PARTS_HELP/, Password.installed_parts_help) if @settings.actions[:help]

    # Save virgin parsed settings
    @virgin_settings = @settings.dup

    # Use saved preferences plan, then defaults plan, if no plan provided in clio
    # FIXME: Will require updating to reflect the approach above.
    @settings.plan = (Preferences.instance.plan.empty? ? Defaults.instance.plan : Preferences.instance.plan) if @settings.plan.empty?

    # Settings merged with Preferences, that merged with Defaults
    @settings.config = Defaults.instance.config.merge(Preferences.instance.config.merge(@settings.config))

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
      part_klass = self.class.const_get(plan_part[0]) # The part descriptor from oro settings
      plan_part[1] = part_klass.middle if plan_part[1].nil?
      current_password << part_klass.get(plan_part[1], @settings.config) # Passing config, Parts don't currently rely on the Preferences singleton
    end

    current_password.shuffle! if @settings.config[:shuffle]
    current_password.join
  end
end
