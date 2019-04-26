# frozen_string_literal: true

RSpec.describe RedashExporter::Queries do
  describe '#initialize' do
    subject { RedashExporter::Queries.new('http://example.com', 'api_key', 'destination') }
    it { is_expected.to be_a RedashExporter::Queries }
  end

  describe '#fetch' do
    let(:target) { RedashExporter::Queries.new('http://example.com', 'api_key', 'destination') }
    subject { target.fetch }
    before do
      mock = double('Fetcher mock', fetch: [])
      allow(RedashExporter::Fetcher).to receive(:new).and_return(mock)
    end
    it { is_expected.to eq [] }
  end
end
