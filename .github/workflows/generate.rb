require 'bolognese'
require 'octokit'

GITHUB = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'], :auto_paginate => true)

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

`bolognese package.json -t datacite > codemeta.json`

def create_branch(branch_name)
  begin
    GITHUB.create_ref(ENV['GITHUB_REPOSITORY'],
                      "heads/#{branch_name}", ENV['GITHUB_SHA'])
  rescue Octokit::UnprocessableEntity
    # Something went wrong
    fail "Something went wrong making the branch"
  end
end

def create_codemeta_file(branch_name, short_sha)
  begin
    GITHUB.create_contents( ENV['GITHUB_REPOSITORY'],
                            "codemeta.json",
                            "Creating codemeta.json at #{short_sha}",
                            File.open("codemeta.json").read,
                            :branch => branch_name)
  rescue Octokit::UnprocessableEntity
    fail "Something went wrong uploading the codemeta.json file"
  end
end

def create_codemeta_pull_request(branch_name, short_sha)
  begin
    GITHUB.create_pull_request( ENV['GITHUB_REPOSITORY'],
                                "master", "#{branch_name}",
                                "Creating pull request with codemeta.json file at #{short_sha}",
                                "If this looks good then :shipit:")
  rescue Octokit::UnprocessableEntity
    fail "Something went wrong creating the pull request"
  end
end

short_sha = ENV['GITHUB_SHA'].slice(0,8)
target_branch = "codemeta.json-#{short_sha}"

create_branch(target_branch)
create_codemeta_file(target_branch, short_sha)
create_codemeta_pull_request(target_branch, short_sha)
