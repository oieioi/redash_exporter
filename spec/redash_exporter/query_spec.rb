# frozen_string_literal: true

RSpec.describe RedashExporter::Query do
  let(:raw) { JSON.parse(query_json) }

  describe '#initialize' do
    subject { RedashExporter::Query.new(raw) }
    it { is_expected.to be_a RedashExporter::Query }
  end

  describe '#[]' do
    let(:target) { RedashExporter::Query.new(raw) }
    subject { target[key] }
    context 'key is string' do
      let(:key) { "name" }
      it { is_expected.to eq 'Test Query' }
    end

    context 'key is symbol' do
      let(:key) { :name }
      it { is_expected.to eq 'Test Query' }
    end
  end

  describe '#to_s' do
    let(:target) { RedashExporter::Query.new(raw) }
    subject { target.to_s }
    it {
      is_expected.to eq <<~CONTENT
        /**
         * Test Query
         *
         * created at 2019-04-24T01:31:39.791956+00:00
         * last updated at 2019-04-24T01:31:39.791996+00:00
         * created by Developer (developer@example.com)
         **/
         select * from mail_logs where company_id = {{company_id}} order by id desc
      CONTENT
    }
  end

  describe '#to_json' do
    let(:target) { RedashExporter::Query.new(raw) }
    subject { target.to_json }
    it { is_expected.to be_a String }
  end

  describe 'sort' do
    subject { [target1, target2, target3].sort }
    let(:target1) { RedashExporter::Query.new(id: 2) }
    let(:target2) { RedashExporter::Query.new(id: 3) }
    let(:target3) { RedashExporter::Query.new(id: 1) }
    it { is_expected.to eq [target3, target1, target2] }
  end

  describe '#export' do
    subject { target.export(*args) }
    let(:target) { RedashExporter::Query.new(raw) }
    let(:args) { nil }
    it do
      expect(RedashExporter::Exporter).to receive(:export)
        .with("#{Dir.pwd}/424-Test Query.sql", target.to_s, force: false)
      subject
    end
  end
end
