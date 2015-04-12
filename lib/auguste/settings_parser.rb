require 'ostruct'
require 'optparse'

# One job, recieves String command line settings, parses them and returns OpenStruct structured settings.
class SettingsParser

  def self.parse(argv) # Ie: an ARGV-style array of the clio

    settings = OpenStruct.new(:plan => [], :config => {}, :actions => {})

    clio_parser = OptionParser.new do |clio_parser_config|

      clio_parser_config.program_name = 'Auguste'
      clio_parser_config.release = 'Generation 2'
      clio_parser_config.version = ['2', '0', 'alpha', '0']
      clio_parser_config.banner = 'Usage: auguste [settings]'
      clio_parser_config.separator ''

      # Parts
      clio_parser_config.separator 'Part settings'
      clio_parser_config.on('-w[OPTIONAL]', '--word[=OPTIONAL]', Integer) do |val|
        settings.plan.push(['Word', val])
      end

      clio_parser_config.on('-n[OPTIONAL]', '--number[=OPTIONAL]', Integer) do |val|
        settings.plan.push(['Number', val])
      end

      clio_parser_config.on('-p[OPTIONAL]', '--punctuation[=OPTIONAL]', Integer) do |val|
        settings.plan.push(['Punctuation', val])
      end

      clio_parser_config.on('-e[OPTIONAL]', '--emoticon[=OPTIONAL]', Integer) do |val|
        settings.plan.push(['Emoticon', val])
      end

      clio_parser_config.on('-b[OPTIONAL]', '--braille[=OPTIONAL]', Integer) do |val|
        settings.plan.push(['Braille', val])
      end

      # Config
      clio_parser_config.separator ''
      clio_parser_config.separator 'Config settings'
      clio_parser_config.on('-dMANDATORY', '--dictionary=MANDATORY', 'The list used to source word parts') do |val|
        val[0] = val[0].capitalize
    		settings.config[:dictionary] = val
      end

    	clio_parser_config.on('-iMANDATORY', '--iterations=MANDATORY', Integer, 'The number of passwords to generate') do |val|
    		settings.config[:iterations] = val
    	end

      clio_parser_config.on('-c', '--[no-]capitalize', 'Capitalize every word part') do |val|
        settings.config[:capitalize] = val
      end

      clio_parser_config.on('-r', '--[no-]capitalize-random', 'Randomly capitalize one letter in every word part') do |val|
        settings.config[:capitalize_random] = val
      end

      clio_parser_config.on('-l', '--[no-]l33t', 'Make one l33t-style replacement per word part') do |val|
        settings.config[:l33t] = val
      end

      clio_parser_config.on('-s', '--[no-]shuffle', 'Randomize map parts') do |val|
        settings.config[:shuffle] = val
      end

      clio_parser_config.on('-f', '--format=MANDATORY', ['json','yml','yaml','string'], 'Results format: string, json, yaml') do |val|
        settings.config[:format] = val
      end

      clio_parser_config.on('-t', '--separator[=OPTIONAL]', 'Separator characters') do |val|
        settings.config[:separator] = eval("val=\"#{val}\"") # FIXME The horror, but how else to take \n as an option and retain it's control nature?  The eval should be removed.
      end

      # Actions
      clio_parser_config.separator ''
      clio_parser_config.separator 'Action settings'
      clio_parser_config.on('--lists', 'Show all available lists') do |val|
        settings.actions[:lists] = val
      end

      clio_parser_config.on('--prefs', '--preferences', 'Show your current preferences') do |val|
        settings.actions[:preferences] = val
      end

      clio_parser_config.on('--defaults', 'Show system defaults') do |val|
        settings.actions[:defaults] = val
      end

      clio_parser_config.on('--set', 'Set passed settings as your preferences') do |val|
        settings.actions[:set] = val
      end

      clio_parser_config.on('--reset', 'Reset your preferences to system defaults') do |val|
        settings.actions[:reset] = val
      end

      clio_parser_config.on('-v', '--verbose', 'Provide verbose feedback, dictionary metadata, and statistics when run') do |val|
        settings.actions[:verbose] = val
      end

    	clio_parser_config.on('-h', '--help', 'Print this dialog') do |val|
        settings.actions[:help] = clio_parser_config.to_s
    	end

      clio_parser_config.on('--version', 'Show version') do |val|
        settings.actions[:version] = clio_parser_config.ver
      end
      clio_parser_config.separator ''
      clio_parser_config.separator 'See dictionary source files for associated licence attributions.'
      clio_parser_config.separator ''

    end # end clio_parser

    argv = argv.is_a?(Array) ? argv : argv.split
    clio_parser.parse!(argv)

    settings

  end # end parse_to_structure

end # end class
