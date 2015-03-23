# Delete any words with non A-Za-z characters
require 'yaml'
words=YAML.load_file('/Users/jwagener/Desktop/german.yml')
words.delete_if{|w| w[/(\W|\d|\c|\s)/] != nil }
File.open('/Users/jwagener/Desktop/german-letters-only.yml', 'w'){|f| f.write words.to_yaml }

# Stem all words and create unique array
require 'yaml'; require 'lingua/stemmer'
stemmer = Lingua::Stemmer.new(:language => "german")
words2 = words=YAML.load_file('/Users/jwagener/Desktop/german-letters-only.yml')
words2.uniq.size # 1331030
words2.each_with_index{|w, index| words2[index] = stemmer.stem(w)}
words2.uniq!.size # 576654
words2.delete_if{|w| w[/[A-Z]/] != nil} ; words2.size # Lowercases: 75550
File.open('/Users/jwagener/Desktop/german-letters-only-lowercases.yml', 'w'){|f| f.write words2.to_yaml }
# words2.each_with_index{|w, index| words2[index] = w.downcase}
# words2.delete_if{|w| w[/[A-Z]/] == nil} ; words2.size # Uppercases: 501104
# File.open('/Users/jwagener/Desktop/german-letters-only-uppercases.yml', 'w'){|f| f.write words2.to_yaml }

# Pick 30k random words
words2 = words=YAML.load_file('/Users/jwagener/Desktop/german-letters-only.yml')
words3 = []; words2_length = words2.length; (0..30000).each{words3 << words2[rand(words2_length)]}
words3.each_with_index{|w, index| words3[index] = w.downcase}
words3.delete_if{|w| w.length <= 2}
words3.uniq!; words2.sort!
File.open('/Users/jwagener/Desktop/german-letters-lowercased.yml', 'w'){|f| f.write words3.to_yaml }
