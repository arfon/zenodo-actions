require 'bolognese'

puts "The repository is #{ENV['GITHUB_REPOSITORY']}"
puts "The commit is #{ENV['GITHUB_SHA']}"

files_to_detect = [
  "package.json"
]

# See what files exist at the repository root
detected = files_to_detect.select { |file| File.exists?(file) }

# Fail the script if none of the desired files are detected
fail unless detected.any?

puts "Working with #{detected.first}"

`cp package.json codemeta.json`
