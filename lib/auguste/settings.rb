require 'singleton'
require 'yaml'
require 'ostruct'
require_relative 'options_parser'

module ClioHelper
  def self.clioize(options)
    clio = []
    options.plan.each{|p| clio << "-#{p[0][0].downcase}#{p[1]}"}
    options.config.each{|p| clio << "--#{p[0].to_s.gsub('_','-')}=#{p[1].to_s.gsub(/\n/, '"\n"')}"} # FIXME This needs to support \t and \r, at least
    clio.join(' ')
  end
  def clio ; ClioHelper.clioize(settings) end # FIXME I spent hours, the location of this is dubious.
  def to_s ; "#{self.class.name}: #{self.clio} (#{self.class::FILE})" end # FIXME This should include Defaults somehow.
end

module SettingsAccessors
  def plan ; settings.plan end
  def plan=(val) ; @settings.plan = val end
  def config ; settings.config end
  def config=(val) ; @settings.config = val end
  def actions ; settings.actions end
  def actions=(val) ; @settings.actions = val end
end

class Defaults
  include ClioHelper, SettingsAccessors, Singleton
  FILE = File.join(File.dirname(__FILE__), 'defaults.yml')

  def initialize ; settings end
  def settings ; @settings ||= YAML::load(File.read(FILE)) end
end

class Preferences
  include ClioHelper, SettingsAccessors, Singleton
  FILE = File.join(Dir.home, '.auguste')

  def initialize
    settings
    reset_defaults unless FileTest.readable?(FILE) # Create preference file if missing
  end

  def settings ; @settings ||= YAML::load(File.read(FILE)) end
  def settings=(options)
    options.delete_field('actions') if options.actions
    File.open(FILE, 'w'){|f| f.write YAML::dump(options)}
    @settings = options
  end

  def reset_defaults ; self.settings = Defaults.instance.settings end
end

# FIXME One of the other singleton approaches here can mean less code: https://practicingruby.com/articles/ruby-and-the-singleton-pattern-dont-get-along
class Options # FIXME Shorter code throughout if this responded to #map and #config, ie: Options.instance.map
  include SettingsAccessors, Singleton
  attr_accessor :settings
  def set(clio) ; @settings = OptionsParser.parse(clio) end
end
