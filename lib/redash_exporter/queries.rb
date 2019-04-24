require 'net/https'
require 'json'
require 'forwardable'
require 'active_support'
require 'active_support/core_ext'
require 'redash_exporter/query'

module RedashExporter
  class Queries
    extend Forwardable
    include Enumerable
    attr_accessor :api_key, :url, :queries
    def_delegators :@queries, :each, :size

    def initialize(url, api_key, dest = "#{__dir__}/../../dest")
      @url = url
      @url = "#{@url}/" unless @url.end_with?('/')
      @api_key = api_key
      @dest = dest
      @queries = []
    end

    def export_all
      dest_dir_path = File.expand_path(@dest)
      puts "Export SQL Files to #{dest_dir_path}"

      @queries.each do |query|
        query.export(dest_dir_path)
      end
      puts "done. Check out #{dest_dir_path}"
    end

    def fetch
      uri = URI.parse("#{@url}api/queries")
      header = {
        Authorization: "Key #{@api_key}"
      }
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      page = 1
      page_size = 250

      loop do
        uri.query = "page=#{page}&page_size=#{page_size}"
        req = Net::HTTP::Get.new(uri.to_s, header)
        res = http.request(req)
        body = JSON.parse(res.body, symbolize_names: true)

        raise "Failed to fetch queries. URI: #{uri}" unless res.is_a?(Net::HTTPSuccess)

        # old API returns all queries as an array
        if body.is_a?(Array)
          @queries = body.map { |q| Query.new(q) }
          break
        end

        # new API
        @queries.push(*body[:results].map { |q| Query.new(q) })

        # next page
        if @queries.size < body[:count]
          page += 1
          # wait...
          sleep 0.5
          next
        end

        break
      end
    end

    def reject!(*args, &block)
      @queries = reject(*args, &block)
    end

    def select!(*args, &block)
      @queries = select(*args, &block)
    end
  end
end
