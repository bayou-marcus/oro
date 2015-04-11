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
      @passwords = @passwords.to_json # FIXME Don't love the @password-fest, clunky.
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
- \t is not set when used as a separator
- Using -e'\r' only yields one password (?)
- The verbose merged options "--separator=" value is mssing \t when -e"\t" is given (which does work)

Ideas
- Would it not make sense that an instance of Password had the 8 settings.config and 1 settings.plan options as instance variables?  Ie: The Object Way.
  And, possibly that defaults and preferences either mixed this approach in or were themselves instances or subclasses of Password.  (Very interesting.)
- The app should likely create a ~/.auguste_dictionaries directory and install the defaults if the folder is missing, and when --install-dictionaries is called (so upgrades work).  Sigh.
- Review and possibly integrate this (word list limitations): https://github.com/bdmac/strong_password
- Consider creating a SecureRandom part option to silence the post-publish defsec encryption trolls.
- Hints about more alphabets can be found here:
  - http://linguistics.stackexchange.com/questions/6173/is-english-the-only-language-except-classical-latin-cyrillic-symbol-languages

Steps
- Add documentation notes, using rdoc/Github conventions. https://help.github.com/articles/github-flavored-markdown/ https://github.com/github/linguist
- Finish tests
- Test on Windows
- Build as gem
- Add gem to RubyGems.org: https://help.github.com/articles/adding-an-existing-project-to-github-using-the-command-line/
- Add gem to a Github account

DOC
Dictionary words that will cause issues with Ruby: false, no, nil, null, off, on, true, yes
Punctuation that causes issues and which I excluded rather than attempting to fix: \ "
