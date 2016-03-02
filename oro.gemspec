require 'rake' # Provide FileList class

Gem::Specification.new do |s|
  s.name        = 'oro'
  s.version     = '1.0.0'
  s.date        = '2016-03-02'
  s.summary     = 'Oro for passwords...'
  s.description = 'A flexible, command-line utility which generates memorable passwords. The enemy knows the system -- Claude Shannon / Auguste Kerckhoffs'
  s.authors     = ['Joel Wagener']
  s.email       = 'bayou.marcus@gmail.com'
  s.executables = ['oro']
  s.files       = FileList['**/**/*']
  s.homepage    = 'http://rubygems.org/gems/oro'
  s.license     = 'The MIT License. http://opensource.org/licenses/mit-license.php' # http://choosealicense.com
  s.required_ruby_version = '~> 2.2'
end
