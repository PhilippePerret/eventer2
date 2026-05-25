require 'json'
require 'fileutils'

class JsonStore
  def read(path, fallback)
    return fallback unless File.exist?(path)

    JSON.parse(File.read(path))
  rescue JSON::ParserError
    fallback
  end

  def write(path, data)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate(data))
    warn("[data] created #{path}")
  end
end
