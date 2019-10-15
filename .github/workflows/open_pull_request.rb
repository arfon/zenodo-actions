require 'octokit'

GITHUB = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'], :auto_paginate => true)

def create_branch(branch_name)
  begin
    GITHUB.create_ref(ENV['GITHUB_REPOSITORY'],
                      "heads/#{branch_name}", ENV['GITHUB_SHA'])
  rescue Octokit::UnprocessableEntity
    # Something went wrong
    fail "Something went wrong making the branch"
  end
end

def create_codemeta_file(branch_name)
  begin
    GITHUB.create_contents( ENV['GITHUB_REPOSITORY'],
                            "codemeta.json",
                            "Creating codemeta.json at #{ENV['GITHUB_SHA']}",
                            File.open("codemeta.json").read,
                            :branch => branch_name)
  rescue Octokit::UnprocessableEntity
    fail "Something went wrong uploading the codemeta.json file"
  end
end

def create_codemeta_pull_request(branch_name)
  begin
    GITHUB.create_pull_request( ENV['GITHUB_REPOSITORY'],
                                "master", "#{branch_name}",
                                "Creating pull request with codemeta.json file at #{ENV['GITHUB_SHA']}",
                                "If this looks good then :shipit:")
  rescue Octokit::UnprocessableEntity
    fail "Something went wrong creating the pull request"
  end
end

short_sha = ENV['GITHUB_SHA'].slice(0,8)
target_branch = "codemeta.json-#{short_sha}"

create_branch(target_branch)
create_codemeta_file(target_branch)
create_codemeta_pull_request(target_branch)
