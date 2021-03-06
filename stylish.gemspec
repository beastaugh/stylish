# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{stylish}
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Benedict Eastaugh"]
  s.date = %q{2009-06-02}
  s.description = %q{A Ruby library for generating cascading stylesheets.}
  s.email = %q{benedict@eastaugh.net}
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "History.txt",
    "README.md",
    "Rakefile",
    "VERSION.yml",
    "lib/stylish.rb",
    "lib/stylish/color.rb",
    "lib/stylish/core.rb",
    "lib/stylish/extended.rb",
    "lib/stylish/formattable.rb",
    "lib/stylish/generate.rb",
    "lib/stylish/numeric.rb",
    "lib/stylish/tree.rb",
    "test/background_test.rb",
    "test/color_test.rb",
    "test/comment_test.rb",
    "test/declaration_test.rb",
    "test/declarations_test.rb",
    "test/formattable_test.rb",
    "test/generate_test.rb",
    "test/image_test.rb",
    "test/length_test.rb",
    "test/position_test.rb",
    "test/rule_test.rb",
    "test/selector_test.rb",
    "test/selectors_test.rb",
    "test/stylesheet_test.rb",
    "test/tree_test.rb",
    "test/variable_test.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://ionfish.github.com/stylish/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Write CSS with Ruby}
  s.test_files = [
    "test/background_test.rb",
    "test/color_test.rb",
    "test/comment_test.rb",
    "test/declaration_test.rb",
    "test/declarations_test.rb",
    "test/formattable_test.rb",
    "test/generate_test.rb",
    "test/image_test.rb",
    "test/length_test.rb",
    "test/position_test.rb",
    "test/rule_test.rb",
    "test/selector_test.rb",
    "test/selectors_test.rb",
    "test/stylesheet_test.rb",
    "test/tree_test.rb",
    "test/variable_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
