module Helpers
  refine String do
    def camelize() # FIXME complete
      self.dup.split(/_/).map{ |word| word.capitalize }.join('') # Ala: http://yehudakatz.com/2010/11/30/ruby-2-0-refinements-in-practice/
    end

    # FIXME Is this used?
    def underscore
      self.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end
  end
end

# Mixed in to the singleton Defaults and Prefernce classes, and the Password class
module OptionsAccessors
  def plan ; settings.plan end
  def plan=(val) ; @settings.plan = val end
  def config ; settings.config end
  def config=(val) ; @settings.config = val end
  def actions ; settings.actions end
  def actions=(val) ; @settings.actions = val end
end

module ClioHelper
  # FIXME This *helper* method requires knowledge of the Password class; move to Password class?
  def self.clioize(options)
    clio = []
    options.plan.each{|part| Password.installed_word_parts.include?(part[0]) ? clio << "-w#{part[1]}" : clio << "-#{part[0][0].downcase}#{part[1]}"}
    options.config.each{|part| clio << "--#{part[0].to_s.gsub('_','-')}=#{part[1].to_s.gsub(/\n/, '"\n"')}"} # FIXME Must at least support \t , \r
    clio.join(' ')
  end
  def clio ; ClioHelper.clioize(settings) end
end

module SettingsInspector
  def to_s ; "#{self.class.name}: #{self.clio} (#{self.class::FILE})" end # FIXME This should include Defaults somehow.
end