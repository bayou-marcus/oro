require 'singleton'
require 'yaml'
require 'ostruct'

# FIXME One of the other singleton approaches here can mean less code: https://practicingruby.com/articles/ruby-and-the-singleton-pattern-dont-get-along
class Settings
  include Singleton

  FILE = ''

  def self.clioize(options)
    clio = []
    options.format.each{|p| clio << "-#{p[0][0].downcase}#{p[1]}"}
    options.config.each{|p| clio << "--#{p[0].to_s.gsub('_','-')}=#{p[1].to_s.gsub(/\n/, '"\n"')}"} # FIXME This needs to support \t and \r, at least
    clio.join(' ')
  end

  def clio ; Settings.clioize(settings) end

  def to_s ; "#{self.class.name}: #{self.clio} (#{self.class::FILE})" end # FIXME This should include Defaults somehow.
end

  class Defaults < Settings
    FILE = File.join(File.dirname(__FILE__), 'defaults.yml')
    def settings ; @settings ||= YAML::load(File.read(FILE)) end
  end

  class Preferences < Settings
    FILE = File.join(Dir.home, '.auguste')
    def initialize ; reset_defaults unless FileTest.readable?(FILE) end # Create preference file if missing

    def settings ; @settings ||= YAML::load(File.read(FILE)) end
    def settings=(options)
      options.delete_field('actions') if options.actions
      File.open(FILE, 'w'){|f| f.write YAML::dump(options)}
      options
    end

    def reset_defaults ; self.settings = Defaults.instance.settings end
  end

class Options
  include Singleton

  # FIXME Shorter code throughout if this responded to #map and #config, ie: Options.instance.map
  attr_accessor :settings

  def components(options) # FIXME Unused, but returns class parts needed by settings.  Implement instatation based on this?  Would move Punctuation and Number to files.  Other impact/changes...  Maybe load all classes, but keep @list separate from the class, and add @list via metaprogramming only if needed, by finding a matching .yml file.  This would allow for some smart part classes.  They could check and see if there is a file match, if so add list, if not get list some other way (ie: dynamic lists like pig-latin, truly random secrets) Ie: Part.descendants.each{|d| d.add_list}, and add_list checks for files, on fail does something else (for dynamic lists).  Allows treating all lists much more uniformly and better encapsulated.
    parts = []
    options.format.each do |part|
      part[0] == 'Word' ? parts << options.config[:dictionary] : parts << part[0]
    end
    parts.uniq
  end
end