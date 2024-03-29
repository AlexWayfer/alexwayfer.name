# frozen_string_literal: true

module Compile
	class AssetsCommand < BaseCommand
		## CLI command for raw assets copying
		class CopyCommand < BaseCommand
			ASSETS_DIRECTORY = "#{ROOT_DIR}/assets".freeze

			def execute
				%w[images/**/*.{jp{,e}g,webp,svg}].each do |pattern|
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
end
