#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative '_common'

## Load data from YAML files and make `OpenStruct` object (for a prettier code)

require 'ostruct'

def initialize_open_struct_deeply(value)
	case value
	when Hash then OpenStruct.new(value.transform_values { |hash_value| send __method__, hash_value })
	when Array then value.map { |element| send __method__, element }
	else value
	end
end

root_dir = "#{__dir__}/.."

data = OpenStruct.new(
	Dir.glob("#{root_dir}/data/*.y{a,}ml").each_with_object({}) do |data_file_name, result|
		key = File.basename data_file_name, '.*'
		result[key] = initialize_open_struct_deeply YAML.load_file data_file_name
	end
)

## Compilation preparations

require 'fileutils'

compiled_directory = "#{root_dir}/compiled"

puts "Cleaning #{compiled_directory.sub(Dir.getwd, '')}..."
FileUtils.rm_r Dir.glob "#{compiled_directory}/*"

unless Dir.exist? compiled_directory
	puts "Creating #{compiled_directory.sub(Dir.getwd, '')}..."
	FileUtils.mkdir_p compiled_directory
end

## Copy third-party assets

assets_directory = "#{root_dir}/assets"

%w[scripts/lib/*.js images/**/*.{jpg,svg}].each do |files_pattern|
	Dir.glob("#{assets_directory}/#{files_pattern}") do |file_name|
		relative_path = Pathname.new(file_name).relative_path_from(assets_directory)
		target_file_path = "#{compiled_directory}/#{relative_path}"
		FileUtils.mkdir_p File.dirname target_file_path
		FileUtils.cp file_name, target_file_path
	end
end

## Compile assets

system 'npm run compile'

## Compile pages

require 'kramdown'
require 'erb'

pages_directory = "#{root_dir}/pages"
layout_erb = ERB.new File.read "#{pages_directory}/layout.html.erb"

require 'date'
require 'moments'
birthday = Date.new(1994, 9, 1)

url_with_mtime = ->(path) { "#{path}?v=#{File.mtime("#{compiled_directory}/#{path}").to_i}" }

Dir.glob("#{pages_directory}/*.md{,.erb}").each do |page_file_name|
	puts "Rendering #{page_file_name.sub(Dir.getwd, '')}..."

	rendered_page =
		ERB.new(File.read(page_file_name)).result_with_hash(data: data, birthday: birthday)

	File.write(
		"#{compiled_directory}/#{File.basename(page_file_name, '.*')}.html",
		layout_erb.result_with_hash(
			url_with_mtime: url_with_mtime,
			render_partial: (lambda do |file_name, **variables|
				ERB.new(File.read("#{pages_directory}/_#{file_name}.html.erb")).result_with_hash(
					url_with_mtime: url_with_mtime, **variables
				)
			end),
			page_content: Kramdown::Document.new(rendered_page).to_html,
			birthday: birthday
		)
	)
end
