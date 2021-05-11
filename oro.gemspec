require 'rake' # Provide FileList class

Gem::Specification.new do |s|
  s.name        = 'oro'
  s.version     = '1.0.3'
  s.date        = '2021-05-11'
  s.summary     = 'Oro for passwords...'
  s.description = 'A flexible, command-line utility which generates memorable passwords. The enemy knows the system -- Claude Shannon / Auguste Kerckhoffs'
  s.authors     = ['Bayou Marcus']
  s.email       = 'bayou.marcus@gmail.com'
  s.executables = ['oro']
  s.files       = FileList['**/**/*']
  s.homepage    = 'https://github.com/bayou-marcus/oro'
  s.license     = 'MIT' # http://choosealicense.com ; https://spdx.org/licenses/MIT.html
  s.required_ruby_version = '~> 2.6'
end
