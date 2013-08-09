require 'rake/testtask'
require "teaspoon/console"

namespace 'spec' do
  desc "Run the javascript test"
  task :javascript => :environment do
    puts "\n\n===== Starting Javascript Test =====\n\n"
    fail if Teaspoon::Console.new({suite: ENV["suite"]}).execute
    puts "===== Javascript Test Complete =====\n\n\n"
  end
end

Rake::TestTask.new(:default => "spec:javascript") do |test|
  test.pattern = 'spec/javascript/*_test.rb'
  test.verbose = true
end