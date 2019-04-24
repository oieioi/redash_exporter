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

    def initialize(api_key, url, dest = "#{__dir__}/../../dest")
      @api_key = api_key
      @url = url
      @url = "#{@url}/" unless @url.end_with?('/')
      @dest = dest
      fetch
    end

    def export
      dest_dir_path = File.expand_path(@dest)
      puts "Export SQL Files to #{dest_dir_path}"

      @queries.each do |query|
        query.export(dest_dir_path)
      end
      puts "done. Check out #{dest_dir_path}"
    end

    def sort_by(column_name)
      @queries.each { |q| q.sort_key = column_name }
      @queries.sort
    end

    def sort_by!(column_name)
      @queries = sort_by(column_name)
    end

    def fetch
      uri = URI.parse("#{@url}api/queries")
      header = {
        Authorization: "Key #{@api_key}"
      }
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      req = Net::HTTP::Get.new(uri.path, header)
      res = http.request(req)
      body = JSON.parse(res.body)
      @queries = if body.is_a?(Array)
                   body.map { |q| Query.new(q) }
                 elsif body.is_a?(Hash)
                   body['results'].map { |q| Query.new(q) }
                 end
    end
  end
end
