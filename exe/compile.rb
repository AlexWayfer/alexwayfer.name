#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative '_common'

require 'gorilla_patch/symbolize'

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

def operation(description)
	puts
	puts "#{description}..."
	yield
	puts 'Done.'
end

require 'fileutils'

COMPILED_DIRECTORY = "#{root_dir}/compiled"

def relative_path(full_path, base_path = Dir.getwd)
	Pathname.new(full_path).relative_path_from(base_path)
end

operation "Cleaning #{relative_path COMPILED_DIRECTORY}" do
	FileUtils.rm_r Dir.glob "#{COMPILED_DIRECTORY}/*"
end

unless Dir.exist? COMPILED_DIRECTORY
	operation "Creating #{relative_path COMPILED_DIRECTORY}" do
		FileUtils.mkdir_p COMPILED_DIRECTORY
	end
end

COMPILED_TMP_DIRECTORY = "#{COMPILED_DIRECTORY}/tmp"

operation "Creating #{relative_path COMPILED_TMP_DIRECTORY}" do
	FileUtils.mkdir_p COMPILED_TMP_DIRECTORY
end

## Copy third-party assets

assets_directory = "#{root_dir}/assets"

%w[scripts/lib/*.js images/**/*.{jp{,e}g,webp,svg}].each do |files_pattern|
	Dir.glob("#{assets_directory}/#{files_pattern}") do |file_name|
		relative_file_path = relative_path file_name, assets_directory

		operation "Copying #{relative_file_path}" do
			target_file_path = "#{COMPILED_DIRECTORY}/#{relative_file_path}"
			FileUtils.mkdir_p File.dirname target_file_path
			FileUtils.cp file_name, target_file_path
		end
	end
end

## Compile assets

abort unless system 'npm run compile'

## Compile pages

require 'kramdown'
require 'erb'

TEMPLATES_DIRECTORY = "#{root_dir}/templates"
SITE_TEMPLATES_DIRECTORY = "#{TEMPLATES_DIRECTORY}/site"
PAGES_DIRECTORY = "#{SITE_TEMPLATES_DIRECTORY}/pages"

def initialize_layout(directory)
	ERB.new File.read "#{directory}/layout.html.erb"
end

site_layout_erb = initialize_layout PAGES_DIRECTORY

require 'date'
require 'moments'
BIRTHDAY = Date.new(1994, 9, 1)

profile_config_file_path = "#{root_dir}/config/profile.yaml"

unless File.exist? profile_config_file_path
	abort unless system 'toys config check'
end

using GorillaPatch::Symbolize

PROFILE = YAML.load_file(profile_config_file_path).symbolize_keys

SITE_TITLE = "#{PROFILE[:username]}'s Site"

PHOTO_PATH = 'images/photo.jpeg'

## Helper methods for rendering

def url_with_mtime(path)
	"#{path}?v=#{File.mtime("#{COMPILED_DIRECTORY}/#{path}").to_i}"
end

def render(content, **variables)
	ERB.new(content).result_with_hash(variables)
end

def render_file(file_name, **variables)
	render File.read(file_name), **variables
end

def render_partial(
	file_name, base_dir: SITE_TEMPLATES_DIRECTORY, remove_newlines: false, **variables
)
	file_name = Dir.glob("#{base_dir}/partials/#{file_name}.*.erb").first
	result = render_file(file_name, **variables)
	result.gsub!(/\n[\t ]*/, '') if remove_newlines
	result
end

def svg_icon(name)
	render_partial :svg_icon, name: name, remove_newlines: true
end

def external_link(text, href)
	render_partial :external_link, text: text, href: href, remove_newlines: true
end

def basename_without_extensions(full_name)
	File.basename(full_name).split('.', 2).first
end

## Render Markdown pages

Dir.glob("#{PAGES_DIRECTORY}/*.md{,.erb}").each do |page_file_name|
	operation "Rendering #{relative_path page_file_name}" do
		rendered_page = render_file page_file_name, data: data

		page_file_basename = basename_without_extensions page_file_name

		## Lint Markdown
		markdown_temp_file_name = "#{COMPILED_DIRECTORY}/#{page_file_basename}.md"
		File.write markdown_temp_file_name, rendered_page
		system "npm run lint:markdown -- #{markdown_temp_file_name} --no-stdout"
		File.delete markdown_temp_file_name

		File.write(
			"#{COMPILED_DIRECTORY}/#{page_file_basename}.html",
			site_layout_erb.result_with_hash(
				page_content: Kramdown::Document.new(rendered_page).to_html
			)
		)
	end
end

## Clear temp directory

operation "Deleting #{COMPILED_TMP_DIRECTORY}" do
	FileUtils.rm_r COMPILED_TMP_DIRECTORY
end
