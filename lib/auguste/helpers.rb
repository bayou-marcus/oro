# Rails-style string helpers
module Helpers
  refine String do
    def camelize
      dup.split(/_/).map(&:capitalize).join('') # Modified from: http://yehudakatz.com/2010/11/30/ruby-2-0-refinements-in-practice/
    end

    # Not presently used
    def underscore
      gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').tr('-', '_').downcase
    end
  end
end

# Mixed in to the singleton Defaults and Preference classes, and the Password class
module SettingsAccessors
  def plan
    settings.plan
  end

  def plan=(val)
    @settings.plan = val
  end

  def config
    settings.config
  end

  def config=(val)
    @settings.config = val
  end

  def actions
    settings.actions
  end

  def actions=(val)
    @settings.actions = val
  end
end

# Helper methods for turning settings back into clio
module ClioHelper
  def self.clioize(settings)
    clio = []
    settings.plan.each { |part| Password.installed_word_parts.include?(part[0]) ? clio << "-w#{part[1]}" : clio << "-#{part[0][0].downcase}#{part[1]}" }
    settings.config.each { |part| clio << "--#{part[0].to_s.gsub('_', '-')}=#{part[1].to_s.gsub(/\n|\t|\r/, "\n" => '"\n"', "\t" => '"\t"', "\r" => '"\r"')}" }
    clio.join(' ')
  end
  def clio
    ClioHelper.clioize(settings)
  end
end

# Custom inspection
module SettingsInspector
  def to_s
    "#{self.class.name}: #{self.clio} (#{self.class::FILE})"
  end
end
