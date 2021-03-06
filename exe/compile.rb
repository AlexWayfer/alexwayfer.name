#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative '_bundler_setup'

require_relative 'compile/all_command'

module Compile
	## The root command for CLI
	class RootCommand < BaseCommand
		self.default_subcommand = 'all'

		subcommand 'assets', 'Compile assets', AssetsCommand
		subcommand 'pages', 'Compile pages', PagesCommand
		subcommand 'pdf', 'Compile PDF', PDFCommand
		subcommand 'all', 'Compile all', AllCommand
	end
end

Compile::RootCommand.run
