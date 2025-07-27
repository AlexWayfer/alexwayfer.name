# frozen_string_literal: true

require 'erb'
require 'forwardable'
require 'ostruct'

module Compile
	## View object for render
	class ViewObject
		# extend Forwardable
		#
		# def_delegators 'self.class', :render

		class << self
			def inherited(subclass)
				super
				subclass.define_bind_method
			end

			def render_file(file_name, **)
				render File.read(file_name), **
			end

			def render_erb(erb, **)
				view_object = new(**)
				erb.result(view_object.bind)
			end

			def render(content, **)
				render_erb ERB.new(content), **
			end

			def define_bind_method
				class_eval <<~SRC, __FILE__, __LINE__ + 1
					def bind
						binding
					end
				SRC
			end
		end

		attr_reader :data

		def initialize(additional_data: {}, **data)
			@data = data.merge(additional_data)
		end

		define_bind_method

		private

		def render(*)
			self.class.public_send(__method__, *)
		end

		def render_partial(
			file_name, base_dir:, remove_newlines: false, **variables
		)
			file_name = Dir.glob("#{base_dir}/partials/#{file_name}.*.erb").first
			result = self.class.render_file(file_name, **@data, **variables)
			result.gsub!(/\n[\t ]*/, '') if remove_newlines
			result
		end

		def external_link(text, href)
			render_partial :external_link, text:, href:, remove_newlines: true
		end
	end
end
