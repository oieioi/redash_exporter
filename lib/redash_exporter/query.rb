require 'zaru'

module RedashExporter
  class Query
    attr_accessor :sort_key, :data

    def initialize(raw)
      @data = raw
      @sort_key = 'retrieved_at'
    end

    def to_s
      <<~EOS
      /**
       * #{@data['name']}
       * created at #{@data['created_at']}
       * last updated at #{@data['updated_at']}
       * created by #{user['name']} (#{user['email']})
       **/

      #{@data['query']}
      EOS
    end

    def <=>
      @data[@sort_key] || -1
    end

    def export(dir)
      path = "#{dir}/#{file_name}"

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

    def user
      @data['user'] || {}
    end

    def file_name
      Zaru.sanitize! "#{@data['id']}-#{@data['name']}.sql"
    end
  end
end
