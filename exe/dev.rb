#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative '_bundler_setup'

require 'filewatcher/matrix'

system 'exe/compile.rb'

puts
puts 'Starting filewatchers...'
Filewatcher::Matrix.new('filewatchers.yaml').start
