require 'rubygems'

require 'rake/gempackagetask'

spec = eval(File.read(File.join(File.dirname(__FILE__), 'rsolr-ext.gemspec')))

task :default => [:package]

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end