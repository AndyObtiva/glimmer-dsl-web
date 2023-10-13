require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
begin
  jeweler_required = require 'jeweler'
rescue Exception
  jeweler_required = nil
end
unless jeweler_required.nil?
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
    gem.name = "glimmer-dsl-web"
    gem.homepage = "http://github.com/AndyObtiva/glimmer-dsl-web"
    gem.license = "MIT"
    gem.summary = %Q{Glimmer DSL for Web}
    gem.description = %Q{Glimmer DSL for Web (Ruby in the Browser Web GUI Library) - Enables frontend GUI development with Ruby by adopting a DSL that follows web-like HTML syntax, enabling the transfer of HTML/CSS/JS skills to Ruby frontend development. This library relies on Opal Ruby.}
    gem.email = "andy.am@gmail.com"
    gem.authors = ["Andy Maleh"]
    gem.executables = []
    gem.files = Dir['README.md', 'CHANGELOG.md', 'VERSION', 'LICENSE.txt', 'glimmer-dsl-web.gemspec', 'lib/**/*', 'samples/**/*', 'app/**/*']
    # dependencies defined in Gemfile
  end
  Jeweler::RubygemsDotOrgTasks.new
end

#require 'opal/rspec/rake_task'
#Opal::RSpec::RakeTask.new(:default) do |server, task|
#  server.append_path File.expand_path('../lib', __FILE__)
#  require 'opal-async'
#  Opal.use_gem('glimmer-dsl-web')
#end

task :no_puts_debuggerer do
  ENV['puts_debuggerer'] = 'false'
end

namespace :build do
  desc 'Builds without running specs for quick testing, but not release'
  task :prototype => :no_puts_debuggerer do
    Rake::Task['build'].execute
  end
end

# Rake::Task["build"].enhance [:no_puts_debuggerer, :spec] #TODO enable once opal specs are running
task :default do
  puts "To run opal specs, visit: http://localhost:9292 "
  system `rackup`
end
