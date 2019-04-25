# frozen_string_literal: true

require 'net/https'
require 'json'

module RedashExporter
  class Fetcher
    def initialize(url, api_key, params = {})
      @url = url.gsub(%r{/$}, '')
      @api_key = api_key
      @params = params
    end

    def fetch
      result = []
      has_more = true

      while has_more
        body = request("#{@url}?#{@params.to_param}")

        # old web API returns all queries as an array
        return body if body.is_a?(Array)

        # new web API
        result.push(*body[:results])

        has_more = @params[:page].present? && result.size < body[:count]

        # wait for next request
        if has_more
          @params[:page] += 1
          sleep 0.5
        end
      end

      result
    end

    private

    def request(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      req = Net::HTTP::Get.new(uri.to_s, header)
      res = http.request(req)

      raise "Failed to fetch #{uri}" unless res.is_a?(Net::HTTPSuccess)

      JSON.parse(res.body, symbolize_names: true)
    end

    def header
      {
        Authorization: "Key #{@api_key}"
      }
    end
  end
end
