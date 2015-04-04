require_relative 'parts'
require_relative 'settings'

# FIXME This should be a functional and wholly self-contained class, where when you create an instance of it with no params, it gives you back a password (maybe based on random parts and lengths).  If you pass options, then it gives you one like you requested. That would mean all parts namespaced here, defaults separated from Preference to a new singleton (probably best done that way anyway), possibly moving clioize here, and giving params to intitialize instead of having it read from Preference.instance.  Perhaps things like Password.lists and Password.dictionaries should be here as well.
# This should have an instance variable that saves the plan. Once set, calling .pw will issue new passwords based on that plan.
class Password
  attr_reader :pw

  def self.components(options) # FIXME Unused, but returns class parts needed by settings.  Implement instantiation based on this?  Would move Punctuation and Number to files.  Other impact/changes...  Maybe load all classes, but keep @list separate from the class, and add @list via metaprogramming only if needed, by finding a matching .yml file.  This would allow for some smart part classes.  They could check and see if there is a file match, if so add list, if not get list some other way (ie: dynamic lists like pig-latin, truly random secrets) Ie: Part.descendants.each{|d| d.add_list}, and add_list checks for files, on fail does something else (for dynamic lists).  Allows treating all lists much more uniformly and better encapsulated.
    parts = []
    options.plan.each do |part|
      part[0] == 'Word' ? parts << options.config[:dictionary] : parts << part[0]
    end
    parts.uniq
  end

  def self.length
    length = 0
    Options.instance.plan.each do |part|
      if part[0] == 'Word'
        length += part[1].nil? ? Object.const_get(Options.instance.config[:dictionary]).middle : part[1] # FIXME Dry up the frequent Object.const_get calls? Encapsulation seems dubious.
      else
        length += part[1].nil? ? Object.const_get(part[0]).middle : part[1]
      end
    end
    Options.instance.config.has_key?(:l33t) && Options.instance.config[:l33t] == true ? "#{length}+" : length.to_s # Precision bets are off with l33t; && likely uneeded
  end

  def initialize
    current_password = []

    for map_part in Options.instance.plan do
      case map_part[0]
      when 'Word'
        map_part[0] = Options.instance.config[:dictionary]
        map_part[1] = Object.const_get(Options.instance.config[:dictionary]).middle if map_part[1].nil?
      when 'Number', 'Punctuation'
        map_part[1] = 1 if map_part[1].nil?
      end

      part_klass = self.class.const_get(map_part[0]) # The part descriptor from auguste options
      current_password << part_klass.get(map_part[1], Options.instance.config) # Passing config, Parts don't currently rely on the Preference singleton
    end

    current_password.shuffle! if Options.instance.config[:shuffle]
    @pw = current_password.join
  end
end
