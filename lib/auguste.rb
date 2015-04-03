#!/usr/bin/env ruby

require_relative 'auguste/settings'
require_relative 'auguste/options_parser'
require_relative 'auguste/password'
require_relative 'auguste/assembly_line'
require 'byebug' # FIXME rm

# LET'S make passwords

time = Benchmark.measure do

  begin

    # Create ~/.auguste_preferences if missing
    Preferences.instance

    # Parse clio, set options
    Options.instance.set(ARGV)

    # Manage actions here (and retain single responsibility principle for OptionsParser)
    Options.instance.actions.each_pair do |action, val|
      case action
      when :lists
        AssemblyLine.instantiate_part_klasses(:all)
        AssemblyLine.lists ; exit
      when :preferences
        puts Preferences.instance.clio ; exit
      when :defaults
        puts Defaults.instance.clio ; exit
      when :set
        Preferences.instance.settings = Options.instance.settings
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

    # Use preference map if none provided in clio
    Options.instance.plan = Preferences.instance.plan if Options.instance.plan.empty?

    # Merge default config with any options given
    # FIXME Should this be moved to the Defaults or Preferences class?
    Options.instance.config = Defaults.instance.config.merge(Options.instance.config)

    # Create part classes
    AssemblyLine.instantiate_part_klasses(Options.instance.config[:dictionary]) # Here after OptionsParser, and not in PartKlasses, to support verbose mode which is set at run time & Part.middle

    # Be verbose if requested
    warn(Preferences.instance.to_s, "Merged options: #{ClioHelper.clioize(Options.instance.settings)}", "Password lengths will be: #{Password.length}") if $VERBOSE

    @results = AssemblyLine.new.run

  rescue OptionParser::InvalidOption, OptionParser::AmbiguousOption, OptionParser::MissingArgument, OptionParser::InvalidArgument => e
    puts "Error: #{e.message}"
  rescue NoMatchingListError, ListIsNonContiguousError, MatchlessLengthWordError => e
    puts e.message
  end

end # end Benchmark

# Return results
warn("Time to run: #{time.real}") if $VERBOSE
puts @results

__END__

TODO
- Fixme's
- Review and possibly integrate this (word list limitations): https://github.com/bdmac/strong_password
- Add documentation notes, using rdoc/Github conventions. https://help.github.com/articles/github-flavored-markdown/ https://github.com/github/linguist
- The app should likely create a ~/.auguste_dictionaries directory and install the defaults if the folder is missing, and when --install-dictionaries is called (so upgrades work).  Sigh.
- The Password class should be self-sufficient.  No map/config = random password.
- Consider extending Dictionary classes with modules instead of meta programming to add list parts.
- Preferences loads a dictionary even if the password doesn't use one.  Perhaps add a "parts needed" method to the preference class, which could be called to get a list of the part class to load.  Maybe ideally this should be a file path list for all dictionaries/lists required.  Ie:
    Not: AssemblyLine.instantiate_part_klasses(prfs.options.config[:dictionary])
    But: AssemblyLine.instantiate_part_klasses(prfs.parts)
    Then, just instatiate all classes and add the list method when/where needed via metaprogramming instead of only instatiating what is needed.
    Also, use Ruby in the yaml files for the number and punctuation classes: http://urgetopunt.com/rails/2009/09/12/yaml-config-with-erb.html
- Some things have felt very misplaced, some very well placed.  You may be missing an entity: a password list object.
- Add a clipboard gem and switch?
- The verbose merged options "--separator=" value is mssing \t when -e"\t" is given (which does work)
- \t is not set when used as a separator
- Consider creating a SecureRandom part option to silence the post-publish defsec encryption trolls.
- Finish tests
- Test on Windows
- Build as gem
- Add gem to RubyGems.org: https://help.github.com/articles/adding-an-existing-project-to-github-using-the-command-line/
- Add gem to a Github account
- Hints about more alphabets can be found here:
  - http://linguistics.stackexchange.com/questions/6173/is-english-the-only-language-except-classical-latin-cyrillic-symbol-languages

DOC
Dictionary words that will cause issues with Ruby: false, no, nil, null, off, on, true, yes
Punctuation that causes issues and which I excluded rather than attempting to fix: \ "


NEW APPROACH

Password
@map
@options
  OptionsParser
  Part
    SingleCharacterPart
    WordPart (DictionaryPart?)
    RandomPart (?)
