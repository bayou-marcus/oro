require 'singleton'
require 'yaml'
require 'ostruct'
require_relative 'settings_parser'
require_relative 'helpers'

# Singleton class representing default settings
class Defaults
  include ClioHelper, SettingsAccessors, SettingsInspector, Singleton
  FILE = File.join(File.dirname(__FILE__), 'defaults.yml')

  def initialize
    settings
  end

  def settings
    @settings ||= YAML.safe_load(File.read(FILE), permitted_classes: [OpenStruct, Symbol])
  end
end

# Singleton class representing preferred settings
class Preferences
  include ClioHelper, SettingsAccessors, SettingsInspector, Singleton
  FILE = File.join(Dir.home, '.oro')

  def initialize
    reset_defaults unless FileTest.readable?(FILE) # Create preference file if missing
    settings
  end

  def settings
    @settings ||= YAML.safe_load(File.read(FILE), permitted_classes: [OpenStruct, Symbol])
  end

  def settings=(settings)
    settings.delete_field('actions') if settings.actions
    File.open(FILE, 'w') { |f| f.write YAML.dump(settings) }
    @settings = settings
  end

  def reset_defaults
    self.settings = Defaults.instance.settings
  end
end
