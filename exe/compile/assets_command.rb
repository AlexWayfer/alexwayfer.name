# frozen_string_literal: true

require_relative 'assets_command/all_command'

module Compile
	## CLI command for assets compiling
	class AssetsCommand < BaseCommand
		self.default_subcommand = 'all'

		subcommand 'copy', 'Copy assets', self::CopyCommand
		subcommand 'compile', 'Compile assets', self::CompileCommand
		subcommand 'all', 'Copy and compile assets', self::AllCommand
	end
end
