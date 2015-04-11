require 'singleton'
require 'yaml'
require 'ostruct'
require_relative 'settings_parser'
require_relative 'helpers'


# FIXME One of the other singleton approaches here can mean less code: https://practicingruby.com/articles/ruby-and-the-singleton-pattern-dont-get-along
class Defaults
  include ClioHelper, SettingsAccessors, SettingsInspector, Singleton
  FILE = File.join(File.dirname(__FILE__), 'defaults.yml')

  def initialize ; settings end
  def settings ; @settings ||= YAML::load(File.read(FILE)) end
end


class Preferences
  include ClioHelper, SettingsAccessors, SettingsInspector, Singleton
  FILE = File.join(Dir.home, '.auguste')

  def initialize
    reset_defaults unless FileTest.readable?(FILE) # Create preference file if missing
    settings
  end

  def settings ; @settings ||= YAML::load(File.read(FILE)) end
  def settings=(settings)
    settings.delete_field('actions') if settings.actions
    File.open(FILE, 'w'){|f| f.write YAML::dump(settings)}
    @settings = settings
  end

  def reset_defaults ; self.settings = Defaults.instance.settings end
end
