#!/usr/bin/env ruby

# frozen_string_literal: true

require 'bundler/setup'
Bundler.setup

## Load data from YAML files and make `OpenStruct` object (for a prettier code)

require 'ostruct'

def initialize_open_struct_deeply(value)
	case value
	when Hash then OpenStruct.new(value.transform_values { |hash_value| send __method__, hash_value })
	when Array then value.map { |element| send __method__, element }
	else value
	end
end

require 'yaml'

data = OpenStruct.new(
	Dir.glob("#{__dir__}/data/*.y{a,}ml").each_with_object({}) do |data_file_name, result|
		key = File.basename data_file_name, '.*'
		result[key] = initialize_open_struct_deeply YAML.load_file data_file_name
	end
)

## Compilation preparations

require 'fileutils'

compiled_directory = "#{__dir__}/compiled"

puts "Creating #{compiled_directory.sub(Dir.getwd, '')}..."
FileUtils.mkdir_p compiled_directory

## Compile pages

require 'kramdown'
require 'erb'

pages_directory = "#{__dir__}/pages"
layout_erb = ERB.new File.read "#{pages_directory}/layout.html.erb"

require 'date'
require 'moments'
birthday = Date.new(1994, 9, 1)

Dir.glob("#{pages_directory}/*.md{,.erb}").each do |page_file_name|
	puts "Rendering #{page_file_name.sub(Dir.getwd, '')}..."

	rendered_page =
		ERB.new(File.read(page_file_name)).result_with_hash(data: data, birthday: birthday)

	File.write(
		"#{compiled_directory}/#{File.basename(page_file_name, '.*')}.html",
		layout_erb.result_with_hash(
			page_content: Kramdown::Document.new(rendered_page).to_html,
			birthday: birthday
		)
	)
end

## Compile assets

system 'npm run compile'
