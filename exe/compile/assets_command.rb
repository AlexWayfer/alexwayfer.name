# frozen_string_literal: true

require_relative '_base_command'

module Compile
	## CLI command for assets compiling
	class AssetsCommand < BaseCommand
		ASSETS_DIRECTORY = "#{ROOT_DIR}/assets"

		def execute
			## Copy third-party assets
			copy_raw_assets %w[images/**/*.{jp{,e}g,webp,svg}]

			## Compile assets
			abort unless system 'npm run compile'
		end

		private

		def copy_raw_assets(patterns)
			patterns.each do |pattern|
				Dir.glob("#{ASSETS_DIRECTORY}/#{pattern}") do |file_name|
					relative_file_path = relative_path file_name, ASSETS_DIRECTORY

					operation "Copying #{relative_file_path}" do
						target_file_path = "#{COMPILED_DIR}/#{relative_file_path}"
						FileUtils.mkdir_p File.dirname target_file_path
						FileUtils.cp file_name, target_file_path
					end
				end
			end
		end
	end
end
