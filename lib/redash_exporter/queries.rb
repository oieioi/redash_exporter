# frozen_string_literal: true

require 'forwardable'
require 'active_support'
require 'active_support/core_ext'
require 'redash_exporter/fetcher'
require 'redash_exporter/query'

module RedashExporter
  class Queries
    extend Forwardable
    include Enumerable
    attr_accessor :api_key, :redash_url, :queries
    def_delegators :@queries, :each, :size

    ENDPOINT = "/api/queries"

    def initialize(redash_url, api_key, dest = "#{__dir__}/../../dest")
      @redash_url = redash_url.gsub(%r{/$}, '')
      @api_key = api_key
      @dest = dest
      @queries = []
      @fetcher = Fetcher.new("#{@redash_url}#{ENDPOINT}", @api_key, page: 1, page_size: 250)
    end

    def fetch
      @queries = @fetcher.fetch.map { |q| Query.new(q) }
    end

    def export_all(force: false)
      dest_dir_path = File.expand_path(@dest)
      puts "Export SQL Files to #{dest_dir_path}"

      @queries.each do |query|
        query.export(dir: dest_dir_path, force: force)
      end

      puts "Done. Check out #{dest_dir_path}"
    end

    def reject!(*args, &block)
      @queries = reject(*args, &block)
    end

    def select!(*args, &block)
      @queries = select(*args, &block)
    end
  end
end
