require_relative 'parts'
require_relative 'settings'

# FIXME This should be a functional and wholly self-contained class, where when you create an instance of it with no params, it gives you back a password (maybe based on random parts and lengths).  If you pass options, then it gives you one like you requested. That would mean all parts namespaced here, defaults separated from Preference to a new singleton (probably best done that way anyway), possibly moving clioize here, and giving params to intitialize instead of having it read from Preference.instance.  Perhaps things like Password.lists and Password.dictionaries should be here as well.
class Password
  attr_reader :pw

  def self.length
    length = 0
    Options.instance.settings.format.each do |part|
      if part[0] == 'Word'
        length += part[1].nil? ? Object.const_get(Options.instance.settings.config[:dictionary]).middle : part[1] # FIXME Dry up the frequent Object.const_get calls? Encapsulation seems dubious.
      else
        length += part[1].nil? ? Object.const_get(part[0]).middle : part[1]
      end
    end
    Options.instance.settings.config.has_key?(:l33t) && Options.instance.settings.config[:l33t] == true ? "#{length}+" : length.to_s # Precision bets are off with l33t; && likely uneeded
  end

  def initialize
    current_password = []

    for format_part in Options.instance.settings.format do
      case format_part[0]
      when 'Word'
        format_part[0] = Options.instance.settings.config[:dictionary]
        format_part[1] = Object.const_get(Options.instance.settings.config[:dictionary]).middle if format_part[1].nil?
      when 'Number', 'Punctuation'
        format_part[1] = 1 if format_part[1].nil?
      end

      part_klass = self.class.const_get(format_part[0]) # The part descriptor from auguste options
      current_password << part_klass.get(format_part[1], Options.instance.settings.config) # Passing config, Parts don't currently rely on the Preference singleton
    end

    current_password.shuffle! if Options.instance.settings.config[:shuffle]
    @pw = current_password.join
  end
end
