# A singleton representing preferences written to file, and for converting string command line options to structured ones.
# options (structured clio), preferences (saved to file for the user), defaults (system defaults via file)

require 'singleton'

class Preference

  include Singleton

  DEFAULTS_FILE = File.join(File.dirname(__FILE__), 'preference_defaults.yml')
  PREFERENCE_FILE = File.join(Dir.home, '.auguste_preferences')

  def initialize
    reset_defaults unless FileTest.readable?(PREFERENCE_FILE) # Create preference file if missing
  end

  attr_accessor :options

  def preferences ; @preferences ||= YAML::load(File.read(PREFERENCE_FILE)) end

  def preferences=(options)
    options.delete_field('actions') if options.actions
    File.open(PREFERENCE_FILE, 'w') do |f|
      f.write YAML::dump(options)
    end
    options
  end

  def defaults ; @defaults ||= YAML::load(File.read(DEFAULTS_FILE)) end

  def reset_defaults
    struct = defaults
    File.open(PREFERENCE_FILE, 'w') do |f|
      f.write YAML::dump(struct)
    end
    struct
  end

  def components # FIXME Returns needed class parts.  Implement instatation based on this?  Would move Punctuation and Number to files.  Other impact/changes...  Maybe load all classes, but keep @list separate from the class, and add @list via metaprogramming only if needed, by finding a matching .yml file.  This would allow for some smart part classes.  They could check and see if there is a file match, if so add list, if not get list some other way (ie: dynamic lists like pig-latin, truly random secrets) Ie: Part.descendants.each{|d| d.add_list}, and add_list checks for files, on fail does something else (for dynamic lists).  Allows treating all lists much more uniformly and better encapsulated.
    parts = []
    @options.format.each do |part|
      part[0] == 'Word' ? parts << @options.config[:dictionary] : parts << part[0]
    end
    parts.uniq
  end

  # def clio_options ; Preference.clioize(options) end # FIXME rm
  def clio_preferences ; Preference.clioize(preferences) end
  def clio_defaults ; Preference.clioize(defaults) end

  # Class method turns options into clio
  def self.clioize(options)
    clio = []
    options.format.each{|p| clio << "-#{p[0][0].downcase}#{p[1]}"}
    options.config.each{|p| clio << "--#{p[0].to_s.gsub('_','-')}=#{p[1].to_s.gsub(/\n/, '"\n"')}"} # FIXME This needs to support \t and \r, at least
    clio.join(' ')
  end

  def to_s
    ["Default file: #{DEFAULTS_FILE}",
      "Defaults: #{clio_defaults}",
      "Preference file: #{PREFERENCE_FILE}",
      "Preferences: #{clio_preferences}"].join("\n")    
  end


end
