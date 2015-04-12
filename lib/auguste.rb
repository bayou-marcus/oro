#!/usr/bin/env ruby

require 'benchmark'
require 'yaml'
require 'json'
require 'byebug' # FIXME rm
require_relative 'auguste/settings'
require_relative 'auguste/password'

# LET'S make passwords

time = Benchmark.measure do

  begin

    # Create ~/.auguste_preferences if missing
    Preferences.instance

    # Set settings, parse clio
    password = Password.new(ARGV)

    # Manage actions here (and retain single responsibility principle for SettingsParser)
    password.actions.each_pair do |action, val|
      case action
      when :lists
        Password.installed_summary ; exit
      when :preferences
        puts Preferences.instance.clio ; exit
      when :defaults
        puts Defaults.instance.clio ; exit
      when :set
        Preferences.instance.settings = password.virgin_settings
        puts "Saved preferences\n#{Preferences.instance.clio}"
      when :reset
        Preferences.instance.reset_defaults
        puts "Reset preferences to defaults\n#{Preferences.instance.clio}" ; exit
      when :verbose
        $VERBOSE = true
      when :help
        puts val ; exit
      when :version
        puts val ; exit
      end
    end

    # Be verbose if requested
    warn(Preferences.instance.to_s, "Merged settings: #{ClioHelper.clioize(password.settings)}", "Password lengths will be: #{password.length}") if $VERBOSE

    @passwords = []
    time_passwords = Benchmark.measure do
      (1..password.config[:iterations]).each{ @passwords << password.result }
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

__END__

TODO
Issues
- Fixme's
- Using -t'\r' only yields one password (?)
- Switch all Emoticons to the unicode number, see the emoticon.yml file for 1 working example

Ideas
- The app should likely create a ~/.auguste_dictionaries directory and install the defaults if the folder is missing, and when --install-dictionaries is called (so upgrades work).  Sigh.
- The emoticon and braille parts need some thinking re: inclusion
- Review and possibly integrate this (word list limitations): https://github.com/bdmac/strong_password
- Consider creating a SecureRandom part option to silence the post-publish defsec encryption trolls.
- Would it not make sense that an instance of Password had the 8 settings.config and 1 settings.plan options as instance variables?  Ie: The Object Way.
  And, possibly that defaults and preferences either mixed this approach in or were themselves instances or subclasses of Password.  (Very interesting.)
- Hints about more alphabets can be found here:
  - http://linguistics.stackexchange.com/questions/6173/is-english-the-only-language-except-classical-latin-cyrillic-symbol-languages

Steps
- Add documentation notes, using rdoc/Github conventions. https://help.github.com/articles/github-flavored-markdown/ https://github.com/github/linguist
- Finish tests
- Test on Windows
- Build as gem
- Add gem to RubyGems.org: https://help.github.com/articles/adding-an-existing-project-to-github-using-the-command-line/
- Add gem to a Github account
