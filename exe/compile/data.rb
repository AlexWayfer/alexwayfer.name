# frozen_string_literal: true

require 'ostruct'
require 'yaml'

module Compile
	## Load data from YAML files
	class Data < Hash
		def initialize(yaml_files_directory)
			super()

			Dir.glob("#{yaml_files_directory}/**/*.y{a,}ml") do |file_name|
				keys = file_name.match(%r{^#{yaml_files_directory}/(.+)\.ya?ml$})[1].split('/')

				end_point_result = keys[..-2].reduce(self) do |nested_result, key|
					nested_result[key] ||= {}
				end

				end_point_result[keys.last] = YAML.load_file file_name
			end
		end
	end
end
