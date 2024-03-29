# frozen_string_literal: true

require 'forwardable'
require 'kramdown'
require 'moments'

require_relative 'data'

module Compile
	## CLI command for pages compiling
	class PagesCommand < BaseCommand
		extend Forwardable

		PAGES_TEMPLATES_DIR = "#{TEMPLATES_DIR}/pages".freeze

		def_delegators :view_object_class, :render_partial

		def execute
			@pages_layout_erb = initialize_layout PAGES_TEMPLATES_DIR

			@data = operation 'Loading YAML data' do
				Data.new "#{ROOT_DIR}/data"
			end

			@site_title = "#{PROFILE[:username]}'s Site"

			Dir.glob("#{PAGES_TEMPLATES_DIR}/*.md{,.erb}").each do |page_file_name|
				render_page page_file_name
			end
		end

		private

		def render_page(file_name)
			operation "Rendering #{relative_path file_name}" do
				rendered_page =
					view_object_class.render_file(file_name, profile: PROFILE, additional_data: @data)

				page_file_basename = basename_without_extensions file_name

				lint_markdown_page page_file_basename, rendered_page

				page_file_name = "#{page_file_basename}.html"

				rendered_page = render_page_with_layout(page_file_name, rendered_page)

				File.write "#{COMPILED_DIR}/#{page_file_name}", rendered_page
			end
		end

		def lint_markdown_page(page_file_basename, rendered_page)
			markdown_temp_file_name = "#{COMPILED_DIR}/#{page_file_basename}.md"
			File.write markdown_temp_file_name, rendered_page
			abort unless system "npm exec -- remark -f #{markdown_temp_file_name} --no-stdout"
			File.delete markdown_temp_file_name
		end

		def render_page_with_layout(page_file_name, rendered_page)
			view_object_class.render_erb @pages_layout_erb,
				page_file_name:,
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

			def canonical_url
				page = data[:page_file_name]
				page = '' if page == 'index.html'
				"https://alexwayfer.name/#{page}"
			end

			def svg_icon(name)
				render_partial :svg_icon, name:, remove_newlines: true
			end

			def url_with_mtime(path)
				"#{path}?v=#{File.mtime("#{BaseCommand::COMPILED_DIR}/#{path}").to_i}"
			end

			def render_project_part(part_name, project)
				result = render_partial("project/#{part_name}", project:)
				result.split("\n").join("\n    ")
			end

			def project_header_id(project)
				project[:title].tr(' ', '_')
			end
		end
	end
end
