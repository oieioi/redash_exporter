# frozen_string_literal: true

RSpec.describe RedashExporter::Exporter do
  let(:raw) { JSON.parse(query_json) }
  let(:target) { RedashExporter::Exporter }

  describe '::should_overwrite?' do
    subject { target.should_overwrite?(*args) }
    let(:existed_path) { File.expand_path('../data/file_existed.txt', __dir__) }
    let(:not_existed_path) { File.expand_path('../data/file', __dir__) }

    context 'when file does not exist at path' do
      let(:args) { [not_existed_path] }
      it { is_expected.to eq true }
    end

    context 'when force to overwrite' do
      let(:args) { [not_existed_path, force: true] }
      it { is_expected.to eq true }
    end

    context 'when file exists at path' do
      let(:args) { [existed_path] }
      before do
        mock = double(:gets, strip: res)
        allow(STDIN).to receive(:gets).and_return(mock)
        allow(STDOUT).to receive(:puts)
      end

      context 'when "yes"' do
        let(:res) { 'yes' }
        it { is_expected.to eq true }
      end

      context 'when "no"' do
        let(:res) { 'no' }
        it { is_expected.to eq false }
      end
    end
  end
end
