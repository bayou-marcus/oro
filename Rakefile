require 'rake/testtask'

namespace :auguste do

  Rake::TestTask.new do |task|
    Dir.glob(File.dirname(File.absolute_path(__FILE__)) + 'lib/auguste/*.rb') {|file| require file} # FIXME Seemingly fails to load shit.  
    task.libs << 'lib/auguste/*.rb' # FIXME Have no idea if this is doing anything.
    task.test_files = FileList['test/*_test.rb']
    task.verbose = true
  end

  desc 'Say Hola!'
  task :hola do
    puts 'Hola, Señora!'
  end

end

task :default => 'auguste:test'
