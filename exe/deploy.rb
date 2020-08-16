#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative '_bundler_setup'

require 'yaml'

YAML.load_file('config/deploy.yaml').each do |server|
	command = "scp -r compiled/* #{server[:ssh]}:#{server[:path]}/"
	puts "> #{command}"
	system command
end
