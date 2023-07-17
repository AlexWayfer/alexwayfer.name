# frozen_string_literal: true

self::COMMON_REQUIRED_FIELDS = %w[title description technologies].freeze

self::SPECIFIC_REQUIRED_FIELDS = {
	commercial: %w[position team begin_date end_date].freeze,
	personal: %w[begin_date end_date].freeze,
	job_test: %w[date duration].freeze
}.freeze

desc 'Lint project dates in data'

def run
	require 'yaml'

	result = true

	commercial_projects = load_projects 'commercial'

	result = false unless lint_projects commercial_projects, 'Commercial'

	personal_projects = load_projects 'personal'

	result = false unless lint_projects personal_projects, 'Personal'

	result = false unless lint_job_tests

	exit result ? 0 : 1
end

private

def load_projects(type)
	YAML.load_file "#{context_directory}/data/projects/#{type}.yaml"
end

def lint_projects(projects, projects_type)
	result = true

	projects.each do |project|
		title = "#{projects_type} project \"#{project['title']}\""

		result = false unless lint_required_fields project, title, type: projects_type.downcase.to_sym

		result = false unless lint_dates title, project.slice('begin_date', 'end_date')
	end

	puts "#{projects_type} projects are OK." if result

	result
end

def lint_job_tests
	job_tests = load_projects 'job_tests'

	result = true

	job_tests.each do |job_test|
		title = "Job test \"#{job_test['title']}\""

		result = false unless lint_required_fields job_test, title, type: :job_test

		result = false unless lint_dates title, job_test.slice('date')

		result = false unless lint_duration title, job_test['duration']
	end

	puts 'Job tests are OK.' if result

	result
end

def lint_required_fields(project, title, type:)
	result = true

	required_fields = self.class::COMMON_REQUIRED_FIELDS + self.class::SPECIFIC_REQUIRED_FIELDS[type]

	required_fields.each do |key|
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

self::DURATION_REGEXP = /^\d+(\.\d{1,2})? (hours|days|weeks)$/.freeze

def lint_dates(title, dates)
	result = true

	dates.each do |key, value|
		next if value.match? self.class::DATE_REGEXP

		result = false
		warn "#{title} has incorrect #{key.tr('_', ' ')} format"
	end

	result
end

def lint_duration(title, value)
	return true if value.match? self.class::DURATION_REGEXP

	warn "#{title} has incorrect duration format"

	false
end
