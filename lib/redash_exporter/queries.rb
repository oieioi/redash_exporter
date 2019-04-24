require 'net/https'
require 'json'
require 'forwardable'
require 'active_support'
require 'active_support/core_ext'
require 'redash_exporter/query'

module RedashExporter
  class Queries
    extend Forwardable
    attr_accessor :api_key, :url, :queries
    def_delegators @queries, :each

    def initialize(api_key: ENV['REDASH_API_KEY'], url: ENV['REDASH_URI'])
      @api_key = api_key
      @url = url
      fetch
    end

    def export(dir = "#{__dir__}/../../dest")
      dest_dir_path = File.expand_path(dir)
      @queries.each do |query|
        query.export(dest_dir_path)
      end
    end

    def sort_by(column_name)
      @queries.each { |q| q.sort_key = column_name }
      @queries.sort
    end

    def sort_by!(column_name)
      @queries = sort_by(column_name)
    end

    def fetch
      uri = URI.parse("#{@url}/api/queries")
      header = {
        Authorization: "Key #{@api_key}"
      }
      req = Net::HTTP::Get.new(uri.path, header)
      res = Net::HTTP.start(uri.host, uri.port) { |http|
        http.request(req)
      }

      @queries = JSON.parse(res.body).map { |q| Query.new(q) }
    end
  end
end
