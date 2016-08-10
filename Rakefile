require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :console do
  require 'pry'
  require 'google_music_api'

  def reload!
    # Change 'gem_name' here too:
    files = $LOADED_FEATURES.select { |feat| feat =~ /\/google_music_api\// }
    files.each { |file| load file }
  end

  ARGV.clear
  Pry.start
end

