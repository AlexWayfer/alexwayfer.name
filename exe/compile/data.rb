# frozen_string_literal: true

require 'ostruct'
require 'yaml'

module Compile
	## Load data from YAML files and make `OpenStruct` object (for a prettier code)
	class Data < OpenStruct
		def initialize(yaml_files)
			super(
				yaml_files.each_with_object({}) do |file_name, result|
					key = File.basename file_name, '.*'
					result[key] = initialize_open_struct_deeply YAML.load_file file_name
				end
			)
		end

		private

		def initialize_open_struct_deeply(value)
			case value
			when Hash
				self.class.superclass.new(
					value.transform_values { |hash_value| send __method__, hash_value }
				)
			when Array
				value.map { |element| send __method__, element }
			else
				value
			end
		end
	end
end
