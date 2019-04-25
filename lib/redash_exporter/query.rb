# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'
require 'zaru'
require 'redash_exporter/exporter'

module RedashExporter
  class Query
    attr_accessor :sort_key, :data
    include Comparable

    def initialize(raw)
      @data = raw.deep_symbolize_keys
      @sort_key = :id
    end

    def [](key)
      @data[key.to_sym]
    end

    def to_s
      <<~SQL
        /**
         * #{@data[:name]}
         *
         * created at #{@data[:created_at]}
         * last updated at #{@data[:updated_at]}
         * created by #{@data.dig(:user, :name)} (#{@data.dig(:user, :email)})
         **/
         #{@data[:query]}
      SQL
    end

    def to_json(*_args)
      JSON.generate(@data)
    end

    def <=>(other)
      self[@sort_key] <=> other[@sort_key]
    end

    def export(dir: '.', force: false, **)
      path = File.expand_path("#{dir}/#{file_name}")
      Exporter.export(path, to_s, force: force)
    end

    private

    def file_name
      Zaru.sanitize! "#{@data[:id]}-#{@data[:name]}.sql"
    end
  end
end
