#!/usr/bin/env ruby

require 'benchmark'
require 'yaml'
require 'json'
# require 'byebug'
require_relative 'oro/settings'
require_relative 'oro/password'

# LET'S make passwords

time = Benchmark.measure do
  begin

    # Create ~/.oro preferences file if missing
    Preferences.instance

    # Set settings, parse clio
    password = Password.new(ARGV)

    # Manage actions here (and retain single responsibility principle for SettingsParser)
    password.actions.each_pair do |action, val|
      case action
      when :lists
        puts Password.installed_parts_summary
        exit
      when :preferences
        puts Preferences.instance.clio
        exit
      when :defaults
        puts Defaults.instance.clio
        exit
      when :set
        Preferences.instance.settings = password.virgin_settings
        puts "Saved preferences\n#{Preferences.instance.clio}"
      when :reset
        Preferences.instance.reset_defaults
        puts "Reset preferences to defaults\n#{Preferences.instance.clio}"
        exit
      when :verbose
        $VERBOSE = true
      when :help
        puts val
        exit
      when :version
        puts val
        exit
      end
    end

    # Be verbose if requested
    warn(Preferences.instance.to_s, "Merged settings: #{ClioHelper.clioize(password.settings)}", "Password lengths will be: #{password.length}") if $VERBOSE

    @passwords = []
    time_passwords = Benchmark.measure do
      (1..password.config[:iterations]).each { @passwords << password.result }
    end

    warn("Time to generate #{password.config[:iterations]} passwords: #{time_passwords.real}, #{time_passwords.real / password.config[:iterations]} per password") if $VERBOSE

    # We are done
    case password.config[:format]
    when 'json'
      @passwords = @passwords.to_json
    when 'yaml', 'yml'
      @passwords = @passwords.to_yaml
    when 'string'
      @passwords = @passwords.join(password.config[:separator]).strip
    end

  rescue OptionParser::InvalidOption, OptionParser::AmbiguousOption, OptionParser::MissingArgument, OptionParser::InvalidArgument => e
    puts "Error: #{e.message}"
  rescue NoMatchingListError, ListIsNonContiguousError, MatchlessLengthWordError => e
    puts e.message
  end
end # end Benchmark

# Return results
warn("Time to run: #{time.real}") if $VERBOSE
puts @passwords
