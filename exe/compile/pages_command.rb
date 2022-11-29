# frozen_string_literal: true

require 'date'
require 'forwardable'
require 'kramdown'
require 'moments'

require_relative 'data'

module Compile
	## CLI command for pages compiling
	class PagesCommand < BaseCommand
		extend Forwardable

		PAGES_TEMPLATES_DIR = "#{TEMPLATES_DIR}/pages"
		PROFILE[:birthday] = Date.new(1994, 9, 1)

		PROFILE_PHOTO_PATH_JPEG = 'images/photo.jpeg'

		def_delegators :view_object_class, :render_partial

		def execute
			@pages_layout_erb = initialize_layout PAGES_TEMPLATES_DIR

			@data = operation 'Loading YAML data' do
				Data.new "#{ROOT_DIR}/data"
			end

			@site_title = "#{PROFILE[:username]}'s Site"

			fill_profile_photo_data

			Dir.glob("#{PAGES_TEMPLATES_DIR}/*.md{,.erb}").each do |page_file_name|
				render_page page_file_name
			end
		end

		private

		def fill_profile_photo_data
			PROFILE[:photo] = {
				main: PROFILE_PHOTO_PATH_JPEG,
				additional: %i[webp].each_with_object({}) do |ext, result|
					relative_path = PROFILE_PHOTO_PATH_JPEG.sub(/\.\w+$/, ".#{ext}")
					full_path = "#{COMPILED_DIR}/#{relative_path}"

					next unless File.exist? full_path

					result[ext] = relative_path
				end
			}.freeze
		end

		def render_page(file_name)
			operation "Rendering #{relative_path file_name}" do
				rendered_page = view_object_class.render_file(
					file_name, profile: PROFILE, additional_data: @data
				)

				page_file_basename = basename_without_extensions file_name

				lint_markdown_page page_file_basename, rendered_page

				File.write(
					"#{COMPILED_DIR}/#{page_file_basename}.html",
					render_page_with_layout(rendered_page)
				)
			end
		end

		def lint_markdown_page(page_file_basename, rendered_page)
			markdown_temp_file_name = "#{COMPILED_DIR}/#{page_file_basename}.md"
			File.write markdown_temp_file_name, rendered_page
			abort unless system "npm run lint:markdown -- #{markdown_temp_file_name} --no-stdout"
			File.delete markdown_temp_file_name
		end

		def render_page_with_layout(rendered_page)
			view_object_class.render_erb @pages_layout_erb,
				site_title: @site_title,
				profile: PROFILE,
				page_content: Kramdown::Document.new(rendered_page).to_html,
				pdf_path: relative_path(PDF_PATH, COMPILED_DIR)
		end

		## Private class for view objects
		class ViewObject < Compile::ViewObject
			private

			PROJECTS_TYPES = {
				commercial: 'Commercial projects',
				personal: 'Personal projects',
				job_tests: 'Job tests'
			}.freeze

			def render_partial(file_name, base_dir: PAGES_TEMPLATES_DIR, **options)
				super
			end

			def svg_icon(name)
				render_partial :svg_icon, name: name, remove_newlines: true
			end

			def url_with_mtime(path)
				"#{path}?v=#{File.mtime("#{BaseCommand::COMPILED_DIR}/#{path}").to_i}"
			end

			def render_project_part(part_name, project)
				result = render_partial "project/#{part_name}", project: project
				result.split("\n").join("\n    ")
			end
		end
	end
end
