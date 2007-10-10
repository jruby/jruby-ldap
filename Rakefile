require 'rake'
require 'rake/testtask'

task :default => [:test, :package]

desc "Run all tests"
task :test => [:test_all]

Rake::TestTask.new(:test_all) do |t|
  t.test_files = FileList['test/**/test_*.rb']
  t.libs << 'test'
  t.libs.delete("lib") unless defined?(JRUBY_VERSION)
end


task :filelist do
  puts FileList['pkg/**/*'].inspect
end

MANIFEST = FileList["lib/**/*.rb", "test/**/*.rb", "Rakefile", "LICENSE", "README"]

file "Manifest.txt" => :manifest
task :manifest do
  File.open("Manifest.txt", "w") {|f| MANIFEST.each {|n| f << "#{n}\n"} }
end

Rake::Task['manifest'].invoke # Always regen manifest, so Hoe has up-to-date list of files

begin
  require 'hoe'
  Hoe.new("jruby-ldap", "0.0.1") do |p|
    p.rubyforge_name = "jruby-extras"
    p.url = "http://jruby-extras.rubyforge.org/jruby-ldap"
    p.author = "Ola Bini"
    p.email = "ola.bini@gmail.com"
    p.summary = "Port of Ruby/LDAP to JRuby"
  end.spec.dependencies.delete_if { |dep| dep.name == "hoe" }
rescue LoadError
  puts "You really need Hoe installed to be able to package this gem"
rescue => e
  puts "ignoring error while loading hoe: #{e.to_s}"
end
