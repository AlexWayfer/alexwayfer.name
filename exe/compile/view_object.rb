# frozen_string_literal: true

require 'erb'
require 'forwardable'
require 'ostruct'

module Compile
	## View object for render
	class ViewObject < OpenStruct
		# extend Forwardable
		#
		# def_delegators 'self.class', :render

		class << self
			def render_file(file_name, **variables)
				render File.read(file_name), **variables
			end

			def render_erb(erb, **variables)
				view_object = new(**variables)
				erb.result(view_object.bind)
			end

			def render(content, **variables)
				render_erb ERB.new(content), **variables
			end
		end

		def initialize(**data)
			@data = data
			super
		end

		def bind
			binding
		end

		private

		def render(*args)
			self.class.public_send(__method__, *args)
		end

		def render_partial(
			file_name, base_dir:, remove_newlines: false, **variables
		)
			file_name = Dir.glob("#{base_dir}/partials/#{file_name}.*.erb").first
			result = self.class.render_file(file_name, **@data.merge(variables))
			result.gsub!(/\n[\t ]*/, '') if remove_newlines
			result
		end

		def external_link(text, href)
			render_partial :external_link, text: text, href: href, remove_newlines: true
		end
	end
end
