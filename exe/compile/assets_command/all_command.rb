# frozen_string_literal: true

require_relative 'copy_command'
require_relative 'compile_command'

module Compile
	class AssetsCommand < BaseCommand
		## CLI command for processing all assets
		class AllCommand < BaseCommand
			def execute
				AssetsCommand::CopyCommand.run nil, []

				AssetsCommand::CompileCommand.run nil, []
			end
		end
	end
end
