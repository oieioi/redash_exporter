require 'net/https'
require 'json'
require 'active_support'
require 'active_support/core_ext'
require 'byebug'

module RedashExporter
  class Exporter
    attr_accessor :api_key, :url, :queries

    def initialize(api_key: ENV['REDASH_API_KEY'], url: ENV['REDASH_URI'])
      @api_key = api_key
      @url = url
      fetch
    end

    def export
      @queries.each do |query|
        

      end
    end

    def sort_by(column_name)
      @queries.sort { |q| q[column_name.to_s].presence || 0 }
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
      @queries = JSON.parse(res.body)
    end
  end
end
