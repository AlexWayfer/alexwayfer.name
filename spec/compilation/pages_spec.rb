# frozen_string_literal: true

RSpec.describe 'Compilation Pages' do
	subject(:compile!) { system 'exe/compile.rb pages' }

	let(:compiled_dir) { "#{__dir__}/../../compiled" }

	it { is_expected.to be true }

	describe 'index' do
		subject { File.read("#{compiled_dir}/index.html").tr("\n", ' ') }

		before do
			compile!
		end

		let(:expected_text) do
			<<~TEXT.chomp
				I’ve finished a school in a class with advanced study of physics and mathematics with excellent grades.
			TEXT
		end

		it { is_expected.to include expected_text }

		describe 'it has layout' do
			describe 'header' do
				it { is_expected.to include '<head>' }
			end

			describe 'footer' do
				it { is_expected.to include '<footer>' }
			end
		end

		describe 'it renders variables' do
			let(:expected_text) do
				<<~TEXT.chomp
					Hello. My name is Alexander (Aleksandr) Popov.
				TEXT
			end

			it { is_expected.to include expected_text }
		end
	end
end
