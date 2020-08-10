#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative '_common'

YAML.load_file('config/deploy.yaml').each do |server|
	command = "scp -r compiled/* #{server[:ssh]}:#{server[:path]}/"
	puts "> #{command}"
	system command
end
