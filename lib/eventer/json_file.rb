require 'json'
require 'fileutils'

module Eventer
  class JsonFile
    def self.read(path, fallback)
      return fallback unless File.exist?(path)

      JSON.parse(File.read(path))
    rescue JSON::ParserError
      fallback
    end

    def self.write(path, data)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, JSON.pretty_generate(data))
    end
  end
end
