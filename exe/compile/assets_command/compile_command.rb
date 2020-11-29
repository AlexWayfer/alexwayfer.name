# frozen_string_literal: true

module Compile
	class AssetsCommand < BaseCommand
		## CLI command for assets compiling (linting and building)
		class CompileCommand < BaseCommand
			def execute
				abort unless system 'npm run compile'
			end
		end
	end
end
