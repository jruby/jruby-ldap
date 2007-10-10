require 'rake'
require 'rake/testtask'

task :default => [:test]

desc "Run all tests"
task :test => [:test_all]

Rake::TestTask.new(:test_all) do |t|
  t.test_files = FileList['test/**/test_*.rb']
  t.libs << 'test'
  t.libs.delete("lib") unless defined?(JRUBY_VERSION)
end

