# frozen_string_literal: true

self::REQUIRED_PROJECT_FIELDS = %w[title description technologies begin_date end_date].freeze

def run
	require 'yaml'

	result = true

	projects.each.with_index(1) do |project, index|
		raw_title = project['title']
		title = raw_title ? "Project \"#{raw_title}\"" : "Project ##{index}"

		result &&= lint_required_fields project, title

		result &&= lint_dates title, project.slice('begin_date', 'end_date')
	end

	puts 'Everything is OK.' if result

	exit result ? 0 : 1
end

private

def projects
	@projects ||= YAML.load_file "#{context_directory}/data/projects.yaml"
end

def lint_required_fields(project, title)
	result = true

	self.class::REQUIRED_PROJECT_FIELDS.each do |key|
		next if project[key]

		warn "#{title} has no #{key}"
		result = false
	end

	result
end

self::DATE_REGEXP = /
	^
		(
			(January|February|March|April|May|June|July|August|September|October|November|December)
			\ 20[1-9][0-9]
			|
			now
		)
	$
/x.freeze

def lint_dates(title, dates)
	result = true

	dates.each do |key, value|
		next if value.match? self.class::DATE_REGEXP

		result = false
		warn "#{title} has incorrect #{key.tr('_', ' ')} format"
	end

	result
end
