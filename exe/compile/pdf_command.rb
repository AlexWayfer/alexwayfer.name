# frozen_string_literal: true

require_relative 'site_command'

module Compile
	## CLI command for PDF compiling
	class PDFCommand < SiteCommand
		PDF_TEMPLATES_DIR = "#{TEMPLATES_DIR}/pdf"

		STATIC_PDF_OPTIONS = {
			path: PDF_PATH,
			format: :A4,
			display_header_footer: true,
			margin_left: 0,
			margin_right: 0
		}.freeze

		def execute
			@pdf_layout_erb = initialize_layout PDF_TEMPLATES_DIR

			operation 'Saving HTML as PDF' do
				require 'ferrum'

				browser = Ferrum::Browser.new

				domain = File.read("#{CONFIG_DIR}/nginx.conf").match(/^\s*server_name (.+);$/)[1]

				## https://github.com/rubycdp/ferrum/issues/106
				browser.goto "http://#{domain}"

				browser.pdf pdf_options

				browser.quit
			end
		end

		private

		def render_pdf_templates
			Dir.glob("#{PDF_TEMPLATES_DIR}/*.html{,.erb}")
				.each_with_object({}) do |template_file_name, result|
					next if basename_without_extensions(template_file_name) == 'layout'

					operation "Rendering #{relative_path template_file_name}" do
						template_file_basename = basename_without_extensions template_file_name

						result[template_file_basename.to_sym] =
							view_object_class.render_erb @pdf_layout_erb,
								content: view_object_class.render_file(template_file_name)
					end
				end
		end

		def pdf_options
			pdf_templates = render_pdf_templates

			{
				**STATIC_PDF_OPTIONS,
				header_template: pdf_templates.fetch(:header, ' '),
				footer_template: pdf_templates.fetch(:footer, ' '),
				margin_top: pdf_vertical_margin(pdf_templates.key?(:header)),
				margin_bottom: pdf_vertical_margin(pdf_templates.key?(:footer))
			}
		end

		def pdf_vertical_margin(for_template)
			for_template ? 0.6 : 0.2 ## inches
		end
	end
end