require 'lib/stylish'

desc "Run the Stylish test suite"
task :test do
  testdir = "test"
  Dir.foreach(testdir) do |f|
    path = "#{testdir}/#{f}"
    if File.ftype(path) == "file" && File.basename(f).match(/_test.rb$/)
      load path
    end
  end
end

desc "Run a Stylish example"
task :example do
  require 'examples/tarski'
end
