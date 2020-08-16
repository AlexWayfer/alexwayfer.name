# frozen_string_literal: true

require 'date'
require 'fileutils'
require 'forwardable'
require 'kramdown'
require 'moments'
require 'yaml'

require_relative 'data'
require_relative 'assets_command'
require_relative 'pdf_command'

module Compile
	## CLI command for site compiling
	class SiteCommand < BaseCommand
		extend Forwardable

		SITE_TEMPLATES_DIR = "#{TEMPLATES_DIR}/site"
		PAGES_DIR = "#{SITE_TEMPLATES_DIR}/pages"
		PROFILE[:birthday] = Date.new(1994, 9, 1)
		PROFILE[:photo_path] = 'images/photo.jpeg'

		def_delegators :view_object_class, :render_partial

		def execute
			create_compiled_dir

			AssetsCommand.run

			compile_pages

			PDFCommand.run
		end

		private

		def create_compiled_dir
			operation "Cleaning #{relative_path COMPILED_DIR}" do
				FileUtils.rm_r Dir.glob "#{COMPILED_DIR}/*"
			end

			return if Dir.exist? COMPILED_DIR

			operation "Creating #{relative_path COMPILED_DIR}" do
				FileUtils.mkdir_p COMPILED_DIR
			end
		end

		def compile_pages
			@pages_layout_erb = initialize_layout PAGES_DIR

			@data = operation 'Loading YAML data' do
				Data.new Dir.glob("#{ROOT_DIR}/data/*.y{a,}ml")
			end

			@site_title = "#{PROFILE[:username]}'s Site"

			Dir.glob("#{PAGES_DIR}/*.md{,.erb}").each do |page_file_name|
				render_page page_file_name
			end
		end

		def render_page(file_name)
			operation "Rendering #{relative_path file_name}" do
				rendered_page = view_object_class.render_file file_name, profile: PROFILE, data: @data

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
			system "npm run lint:markdown -- #{markdown_temp_file_name} --no-stdout"
			File.delete markdown_temp_file_name
		end

		def render_page_with_layout(rendered_page)
			view_object_class.render_erb @pages_layout_erb, {
				site_title: @site_title,
				profile: PROFILE,
				page_content: Kramdown::Document.new(rendered_page).to_html,
				pdf_path: PDF_PATH
			}
		end

		## Private class for view objects
		class ViewObject < Compile::ViewObject
			private

			def render_partial(file_name, base_dir: SITE_TEMPLATES_DIR, **options)
				super
			end

			def svg_icon(name)
				render_partial :svg_icon, name: name, remove_newlines: true
			end

			def url_with_mtime(path)
				"#{path}?v=#{File.mtime("#{SiteCommand::COMPILED_DIR}/#{path}").to_i}"
			end
		end
	end
end
