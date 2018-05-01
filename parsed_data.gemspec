require './lib/parsed_data/version'

Gem::Specification.new do |s|
  s.name        = 'parsed_data'
  s.version     = ParsedData::VERSION
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = %q{A library to parse and transform data.}
  s.description = "Data parsing and transformation library."
  s.authors     = ["John Fitisoff"]
  s.email       = 'jfitisoff@yahoo.com'

  s.add_runtime_dependency "activesupport"
  s.add_runtime_dependency "nokogiri"

  s.add_development_dependency "coveralls"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "pry"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"

  s.files = [
    "lib/parsed_data.rb",
    "lib/parsed_data/constants.rb",
    "lib/parsed_data/object.rb",
    "lib/parsed_data/parsed_data.rb",
    "lib/parsed_data/version.rb"
  ]
  s.homepage = 'https://github.com/jfitisoff/parsed_data'
  s.license  = 'MIT'
end
