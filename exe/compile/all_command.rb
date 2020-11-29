# frozen_string_literal: true

require 'fileutils'

require_relative '_base_command'
require_relative 'assets_command'
require_relative 'pages_command'
require_relative 'pdf_command'

module Compile
	## CLI command for compiling all
	class AllCommand < BaseCommand
		def execute
			create_compiled_dir

			AssetsCommand.run nil, []

			PagesCommand.run nil, []

			PDFCommand.run nil, []
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
	end
end
