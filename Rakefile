require 'rake/testtask'

desc "default task"
task :default => [:test]

desc "test"
Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
  t.verbose = true
end

