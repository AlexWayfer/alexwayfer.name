# frozen_string_literal: true

RSpec.describe 'Compilation Pages' do
	subject { system 'exe/compile.rb pages' }

	it { is_expected.to be true }
end
