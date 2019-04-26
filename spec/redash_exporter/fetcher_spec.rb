# frozen_string_literal: true

RSpec.describe RedashExporter::Fetcher do
  describe "#initialize" do
    subject { RedashExporter::Fetcher.new('http://example.org', 'api_key', page: 1, page_size: 2) }
    it { is_expected.to be_a RedashExporter::Fetcher }
  end

  describe '#fetch' do
    let(:target) { RedashExporter::Fetcher.new('http://example.com', 'api_key', query) }
    let(:query) {  { page: 1, page_size: 3 } }

    subject { target.fetch }

    before do
      allow(target).to receive(:request).and_return(res)
    end

    context 'Old Redash API' do
      let(:query) { {} }
      let(:res) do
        [
          JSON.parse(query_json),
          JSON.parse(query_json)
        ]
      end

      it 'calls one request' do
        expect(target).to receive(:request).once
        expect(subject).to eq res
      end
    end

    context 'Latest Redash API' do
      let(:query) { { page: 1, page_size: 1 } }
      let(:res) do
        {
          count: 10,
          page: 1,
          page_size: 1,
          results: [JSON.parse(query_json)]
        }
      end

      it 'calls request "count" times' do
        expect(target).to receive(:request).exactly(10).times
        expect(subject.size).to eq 10
      end
    end
  end
end
