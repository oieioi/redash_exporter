# frozen_string_literal: true

module RedashExporter
  module Exporter
    module_function

    # Export a file.
    #
    # @param file_path [String]
    # @param content [String]
    # @param option [Hash] force: force to overwrite file. default false.
    def export(file_path, content, option = {})
      unless should_overwrite?(file_path, option)
        puts "Not create #{file_path}."
        return
      end

      File.open(file_path, 'w') do |file|
        file.print content
      end
    end

    def should_overwrite?(path, option = {})
      return true if option[:force]
      return true unless File.exist?(path)

      puts "Overwrite #{path}? [yes(y), no(n)]"
      should_overwrite = %w[yes y].include?(STDIN.gets.strip)

      should_overwrite
    end
  end
end
