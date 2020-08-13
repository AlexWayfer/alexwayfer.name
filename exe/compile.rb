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

root_dir = File.expand_path "#{__dir__}/.."

data = OpenStruct.new(
	Dir.glob("#{root_dir}/data/*.y{a,}ml").each_with_object({}) do |data_file_name, result|
		key = File.basename data_file_name, '.*'
		result[key] = initialize_open_struct_deeply YAML.load_file data_file_name
	end
)

## Compilation preparations

require 'fileutils'

COMPILED_DIRECTORY = "#{root_dir}/compiled"

puts "Cleaning #{COMPILED_DIRECTORY.sub(Dir.getwd, '')}..."
FileUtils.rm_r Dir.glob "#{COMPILED_DIRECTORY}/*"

unless Dir.exist? COMPILED_DIRECTORY
	puts "Creating #{COMPILED_DIRECTORY.sub(Dir.getwd, '')}..."
	FileUtils.mkdir_p COMPILED_DIRECTORY
end

## Copy third-party assets

assets_directory = "#{root_dir}/assets"

%w[scripts/lib/*.js images/**/*.{jp{,e}g,webp,svg}].each do |files_pattern|
	Dir.glob("#{assets_directory}/#{files_pattern}") do |file_name|
		relative_path = Pathname.new(file_name).relative_path_from(assets_directory)
		target_file_path = "#{COMPILED_DIRECTORY}/#{relative_path}"
		FileUtils.mkdir_p File.dirname target_file_path
		FileUtils.cp file_name, target_file_path
	end
end

## Compile assets

system 'npm run compile'
puts

## Compile pages

require 'kramdown'
require 'erb'

PAGES_DIRECTORY = "#{root_dir}/pages"
layout_erb = ERB.new File.read "#{PAGES_DIRECTORY}/layout.html.erb"

require 'date'
require 'moments'
birthday = Date.new(1994, 9, 1)

def url_with_mtime(path)
	"#{path}?v=#{File.mtime("#{COMPILED_DIRECTORY}/#{path}").to_i}"
end

def render(content, **variables)
	ERB.new(content).result_with_hash(variables)
end

def render_file(file_name, **variables)
	render File.read(file_name), **variables
end

def render_partial(file_name, **variables)
	file_name = Dir.glob("#{PAGES_DIRECTORY}/partials/#{file_name}.*.erb").first
	render_file(file_name, **variables).gsub(/\n[\t ]*/, '')
end

def svg_icon(name)
	render_partial :svg_icon, name: name
end

def external_link(text, href)
	render_partial :external_link, text: text, href: href
end

Dir.glob("#{PAGES_DIRECTORY}/*.md{,.erb}").each do |page_file_name|
	puts "Rendering #{page_file_name.sub(Dir.getwd, '')}..."

	rendered_page = render_file page_file_name, data: data, birthday: birthday

	page_file_basename = File.basename(page_file_name).split('.', 2).first

	## Lint Markdown
	markdown_temp_file_name = "#{COMPILED_DIRECTORY}/#{page_file_basename}.md"
	File.write markdown_temp_file_name, rendered_page
	system "npm run lint:markdown -- #{markdown_temp_file_name} --no-stdout"
	File.delete markdown_temp_file_name

	File.write(
		"#{COMPILED_DIRECTORY}/#{page_file_basename}.html",
		layout_erb.result_with_hash(
			page_content: Kramdown::Document.new(rendered_page).to_html,
			birthday: birthday
		)
	)
end
