#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative '_bundler_setup'

require_relative 'compile/_base_command'
require_relative 'compile/assets_command'
require_relative 'compile/pdf_command'
require_relative 'compile/site_command'

module Compile
	## The root command for CLI
	class RootCommand < BaseCommand
		self.default_subcommand = 'site'

		subcommand 'assets', 'Compile assets', AssetsCommand
		subcommand 'site', 'Compile site', SiteCommand
		subcommand 'pdf', 'Compile PDF', PDFCommand
	end
end

Compile::RootCommand.run
