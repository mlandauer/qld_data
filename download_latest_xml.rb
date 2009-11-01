#!/usr/bin/env ruby
# Download all the latest XML Hansard files from the Queensland Parliament website and commit them to the current repository.
# This way we have a versioned history of each XML file
#
# This script should be run once a day (at least)

require 'rubygems'
require 'mechanize'
require 'uri'
require 'grit'

url = "http://www.parliament.qld.gov.au/view/legislativeAssembly/hansard.asp?SubArea=latest"
# The xml files are stored in the same directory as this script
data_repository = File.dirname(__FILE__)

agent = WWW::Mechanize.new

page = agent.get(url)

page.links.each do |link|
  if link.href =~ /xml$/i
    filename = link.href.split('/')[-1]
    puts "Downloading #{filename}..."
    # Downloads xml files to the same directory as the one this script is in
    File.open(File.join(data_repository, filename), 'w') do |f|
      f << link.click.body
    end
  end
end

repo = Grit::Repo.new(data_repository)

repo.add("*.xml")
repo.commit_index("File automatically downloaded and committed on #{Time.now}")
repo.git.push
