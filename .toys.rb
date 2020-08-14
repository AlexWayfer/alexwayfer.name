# frozen_string_literal: true

include :bundler, static: true

require 'config_toys'
expand ConfigToys::Template, config_dir: "#{__dir__}/config"

require 'icomoon_toys'
expand IcoMoonToys::Template,
	extract_map: {
		'selection.json' => 'assets/icomoon/selection.json',
		'style.css' => 'assets/styles/lib/icomoon.css',
		'symbol-defs.svg' => 'assets/images/icons/symbol-defs.svg'
	}

tool :rubocop do
	include :exec, exit_on_nonzero_status: true, log_level: Logger::UNKNOWN unless include? :exec

	disable_argument_parsing

	def run
		exec ['rubocop', *args]
	end
end
