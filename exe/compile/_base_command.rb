# frozen_string_literal: true

require 'clamp'
require 'date'
require 'erb'
require 'gorilla_patch/symbolize'
require 'yaml'

require_relative 'view_object'

module Compile
	## Base command for compilation with helpers and constants
	class BaseCommand < Clamp::Command
		ROOT_DIR = File.expand_path "#{__dir__}/../.."
		CONFIG_DIR = "#{ROOT_DIR}/config".freeze
		TEMPLATES_DIR = "#{ROOT_DIR}/templates".freeze
		COMPILED_DIR = "#{ROOT_DIR}/compiled".freeze

		using GorillaPatch::Symbolize

		profile_config_file_path = "#{CONFIG_DIR}/profile.yaml"

		abort unless File.exist?(profile_config_file_path) || system('toys config check')

		PROFILE = YAML.load_file(profile_config_file_path, permitted_classes: [Date]).symbolize_keys

		profile_photo_path_jpeg = 'images/photo.jpeg'

		PROFILE[:photo] = {
			main: profile_photo_path_jpeg,
			additional: %i[webp].each_with_object({}) do |ext, result|
				relative_path = profile_photo_path_jpeg.sub(/\.\w+$/, ".#{ext}")
				full_path = "#{COMPILED_DIR}/#{relative_path}"

				next unless File.exist? full_path

				result[ext] = relative_path
			end
		}.freeze

		PDF_PATH = "#{COMPILED_DIR}/#{PROFILE[:first_name]} #{PROFILE[:last_name]}.pdf".freeze

		private

		def operation(description)
			puts
			puts "#{description}..."
			result = yield
			puts 'Done.'
			result
		end

		def relative_path(full_path, base_path = Dir.getwd)
			Pathname.new(full_path).relative_path_from(base_path)
		end

		def basename_without_extensions(full_name)
			File.basename(full_name).split('.', 2).first
		end

		def initialize_layout(directory)
			ERB.new File.read "#{directory}/layout.html.erb"
		end

		def view_object_class
			self.class.const_defined?(:ViewObject) ? self.class::ViewObject : ViewObject
		end
	end
end
