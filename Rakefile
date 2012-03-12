require 'rake/testtask'
require 'bundler/gem_tasks'

task :default => [:test, :build]

desc "Run all tests"
task :test => [:test_all]

Rake::TestTask.new(:test_all) do |t|
  t.test_files = FileList['test/**/test_*.rb']
  t.libs << 'test'
  t.libs.delete("lib") unless defined?(JRUBY_VERSION)
end

