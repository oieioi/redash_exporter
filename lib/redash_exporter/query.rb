require 'active_support'
require 'active_support/core_ext'
require 'forwardable'
require 'zaru'

module RedashExporter
  class Query
    extend Forwardable
    attr_accessor :sort_key

    def initialize(raw)
      @data = raw.symbolize_keys
      @sort_key = :retrieved_at
    end

    def [](key)
      @data[key.to_sym]
    end

    def to_s
      <<~EOS
      /**
       * #{@data[:name]}
       * created at #{@data[:created_at]}
       * last updated at #{@data[:updated_at]}
       * created by #{@data.dig(:user, :name)} (#{@data.dig(:user, :email)})
       **/

      #{@data[:query]}
      EOS
    end

    def <=>
      @data[@sort_key] || -1
    end

    def export(dir = '.')
      path = File.expand_path("#{dir}/#{file_name}")

      if File.exist?(path)
        puts "overwrite #{path} [yes(y),no(n)] ?"
        ok = %w[yes y ok].include?(STDIN.gets.strip)
        unless ok
          puts "Not create #{path}."
          return
        end
      end

      File.open(path, 'w') do |file|
        file.print to_s
      end
    end

    private

    def file_name
      Zaru.sanitize! "#{@data[:id]}-#{@data[:name]}.sql"
    end
  end
end
