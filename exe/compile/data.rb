# frozen_string_literal: true

require 'ostruct'
require 'gorilla_patch/inflections'

module Compile
	## Load data from native types and make `OpenStruct` object (for a prettier code)
	class Data < OpenStruct
		def initialize(raw_data)
			super raw_data.map { |key, value| [key, process_value(key, value)] }.to_h
		end

		private

		using GorillaPatch::Inflections

		def process_value(key, value)
			camelized_key = key.camelize
			if self.class.const_defined?(camelized_key, false)
				self.class.const_get(camelized_key, false).new value
			else
				initialize_open_struct_deeply value
			end
		end

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

		## Class like an Array with custom `Project`s inside with helper methods
		class Projects < Array
			def initialize(raw_projects)
				super raw_projects.map { |raw_project| Project.new raw_project }
			end

			# private

			## Custom class for project with helper methods
			class Project < Data
				def begin_date
					@begin_date ||= Date.parse super
				end

				def
					@end_date ||= begin
						value = super
						if until_now?
							Date.today

						Date.parse value
					end
				end

				def until_now?
					self[:end_date] == 'now'
				end

				def duration
					result = Moments.difference(begin_date, end_date).to_hash
					if
				end
			end
			private_constant :Project
		end
		private_constant :Projects
	end
end
