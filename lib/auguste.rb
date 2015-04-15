#!/usr/bin/env ruby

require 'benchmark'
require 'yaml'
require 'json'
require 'byebug' # FIXME: rm
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
        Password.installed_summary
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

__END__

TODO
Issues
- Fixme's
- DONE Run rubocop on all files
- Set Rubocop to ignore line length
- Using -t'\r' only yields one password (?)
- Since #get is the only differing method, all lists can be treated as Part instances.  These changes would be needed:
  - DONE A memoized #single_character_list? method would be needed to determine if the list was single part style.
  - DONE The #get method would check #single_character_list? and dispatch to #get_for_single_character_part or # get_for_word_part
  - DONE Write an algorithm that generates single character switches for each part installed.
  - Fix issues with clioize failing due to installed_word_parts missing.
  - Fix issues with installed_word_parts failing, and is installed_part_classes used?
  - Make crafty changes to SettingsParser allowing clio switches based on installed lists
  With these in place:
     1) words from different lists can be specified in the same password.
     2) simply adding a new list would allow it to be used with no changes.
     Example: -l6 -p2 -e4 -m3 -i7 --iterations=5 --shuffle --capitalize --l33t --separator='\t' --format=yaml
  Approaches:
    + argv after parsing has ["n1", "w9", "p2"] remaining, so another OptionsParser could handle those.  Collecting help across the two might be a challenge.
    - The native "--plan x,y,z" requires a comma-separated list (as shown here) to work.  Ugly/unnatural.


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
