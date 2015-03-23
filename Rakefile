require 'rake/testtask'

namespace :auguste do

  Rake::TestTask.new do |task|
    # task.libs << 'lib' # FIXME Fails to load a single thing.
    task.libs << 'lib/**/*.rb' # FIXME Fails to load a single thing.
    # task.pattern = "test/**/*_test.rb" # FIXME Is this a deprecated approach?
    task.test_files = FileList['test/*_test.rb']
    task.verbose = true
  end

  desc 'Say Hola!'
  task :hola do
    puts 'Hola, Señora!'
  end

end

task :default => 'auguste:test'
