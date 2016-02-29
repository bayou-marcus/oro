require 'rake' # Provide FileList class

Gem::Specification.new do |s|
  s.name        = 'auguste'
  s.version     = '1.0.0'
  s.date        = '2016-02-27'
  s.summary     = 'The enemy knows the system.'
  s.description = "Generate memorable passwords on your command line."
  s.authors     = ['Joel Wagener']
  s.email       = 'bayou.marcus@gmail.com'
  s.executables = ['auguste']
  s.files       = FileList['**/**/*']
  s.homepage    = 'http://rubygems.org/gems/auguste'
  s.license     = 'The MIT License. http://opensource.org/licenses/mit-license.php' # http://choosealicense.com
end
