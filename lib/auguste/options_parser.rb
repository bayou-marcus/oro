require 'ostruct'
require 'optparse'

# One job: recieves String command line options, parses them and returns OpenStruct structured options.
class OptionsParser

  def self.parse(argv) # Ie: an ARGV-style array of the clio

    options = OpenStruct.new(:plan => [], :config => {}, :actions => {})

    clio_parser = OptionParser.new do |clio_parser_opts|

      clio_parser_opts.program_name = 'Auguste'
      clio_parser_opts.release = 'Generation 2'
      clio_parser_opts.version = ['2', '0', 'alpha', '0']
      clio_parser_opts.banner = 'Usage: auguste [options]'
      clio_parser_opts.separator ''

      # Parts
      clio_parser_opts.separator 'Part options'
      clio_parser_opts.on('-w[OPTIONAL]', '--word[=OPTIONAL]', Integer) do |val|
        options.plan.push(['Word', val])
      end

      clio_parser_opts.on('-n[OPTIONAL]', '--number[=OPTIONAL]', Integer) do |val|
        options.plan.push(['Number', val])
      end

      clio_parser_opts.on('-p[OPTIONAL]', '--punctuation[=OPTIONAL]', Integer) do |val|
        options.plan.push(['Punctuation', val])
      end

      # Config
      clio_parser_opts.separator ''
      clio_parser_opts.separator 'Config options'
      clio_parser_opts.on('-dMANDATORY', '--dictionary=MANDATORY', 'The list used to source word parts') do |val|
        val[0] = val[0].capitalize
    		options.config[:dictionary] = val
      end

    	clio_parser_opts.on('-iMANDATORY', '--iterations=MANDATORY', Integer, 'The number of passwords to generate') do |val|
    		options.config[:iterations] = val
    	end

      clio_parser_opts.on('-c', '--[no-]capitalize', 'Capitalize every word part') do |val|
        options.config[:capitalize] = val
      end

      clio_parser_opts.on('-r', '--[no-]capitalize-random', 'Randomly capitalize one letter in every word part') do |val|
        options.config[:capitalize_random] = val
      end

      clio_parser_opts.on('-l', '--[no-]l33t', 'Make one l33t-style replacement per word part') do |val|
        options.config[:l33t] = val
      end

      clio_parser_opts.on('-s', '--[no-]shuffle', 'Randomize map parts') do |val|
        options.config[:shuffle] = val
      end

      clio_parser_opts.on('-f', '--format=MANDATORY', ['json','yml','yaml','string'], 'Results format: string, json, yaml') do |val|
        options.config[:format] = val
      end

      clio_parser_opts.on('-e', '--separator[=OPTIONAL]', 'Separator characters') do |val|
        options.config[:separator] = eval("val=\"#{val}\"") # FIXME The horror, but how else to take \n as an option and retain it's control nature?  The eval should be removed.
      end

      # Actions
      clio_parser_opts.separator ''
      clio_parser_opts.separator 'Action options'
      clio_parser_opts.on('--lists', 'Show all available lists') do |val|
        options.actions[:lists] = val
      end

      clio_parser_opts.on('--prefs', '--preferences', 'Show your current preferences') do |val|
        options.actions[:preferences] = val
      end

      clio_parser_opts.on('--defaults', 'Show system defaults') do |val|
        options.actions[:defaults] = val
      end

      clio_parser_opts.on('--set', 'Set passed options as your preferences') do |val|
        options.actions[:set] = val
      end

      clio_parser_opts.on('--reset', 'Reset your preferences to system defaults') do |val|
        options.actions[:reset] = val
      end

      clio_parser_opts.on('-v', '--verbose', 'Provide verbose feedback, dictionary metadata, and statistics when run') do |val|
        options.actions[:verbose] = val
      end

    	clio_parser_opts.on('-h', '--help', 'Print this dialog') do |val|
        options.actions[:help] = clio_parser_opts.to_s
    	end

      clio_parser_opts.on('--version', 'Show version') do |val|
        options.actions[:version] = clio_parser_opts.ver
      end
      clio_parser_opts.separator ''
      clio_parser_opts.separator 'See dictionary source files for associated licence attributions.'
      clio_parser_opts.separator ''

    end # end clio_parser

    argv = argv.is_a?(Array) ? argv : argv.split
    clio_parser.parse!(argv)

    options

  end # end parse_to_structure

end # end class
