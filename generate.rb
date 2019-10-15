require 'octokit'

puts Octokit::VERSION

puts "The repository is #{ENV['GITHUB_REPOSITORY']}"
puts "The commit is #{ENV['GITHUB_SHA']}"
