# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{stylish}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Benedict Eastaugh"]
  s.date = %q{2009-04-05}
  s.description = %q{A Ruby library for generating cascading stylesheets.}
  s.email = %q{benedict@eastaugh.net}
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md", "VERSION.yml", "lib/stylish", "lib/stylish/color.rb", "lib/stylish/core.rb", "lib/stylish/formattable.rb", "lib/stylish/generator.rb", "lib/stylish.rb", "test/background_test.rb", "test/color_test.rb", "test/comment_test.rb", "test/declaration_test.rb", "test/declarations_test.rb", "test/formattable_test.rb", "test/generate_test.rb", "test/rule_test.rb", "test/selector_test.rb", "test/selectors_test.rb", "test/stylesheet_test.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ionfish/stylish}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Write CSS with Ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
