ENV['RACK_ENV'] ||= 'development'
require "rubygems"
require "bundler/setup"

require File.expand_path(File.join(File.dirname(__FILE__), 'gh_res'))

run GithubResume::ResumeApp
