require 'rake/testtask'

namespace :oro do

  Rake::TestTask.new do |task|
    Dir.glob(File.dirname(File.absolute_path(__FILE__)) + 'lib/oro/*.rb') {|file| require file} # FIXME Seemingly fails to load shit.
    task.libs << 'lib/oro/*.rb' # FIXME Have no idea if this is doing anything.
    task.test_files = FileList['test/*_test.rb']
    task.verbose = true
  end

  desc 'Say Hola!'
  task :hola do
    puts 'Hola, Señora!'
  end

end

task :default => 'oro:test'
