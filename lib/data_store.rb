require 'json'
require 'fileutils'

class DataStore
  STATE_FILE = '__state__.json'
  PROJECTS_FILE = '__projects__.json'
  PROJECTS_FOLDER = '__projects__'

  attr_reader :data_dir

  def initialize(data_dir)
    @data_dir = data_dir
  end

  def data_exists?
    Dir.exist?(data_dir)
  end

  def ensure_data_dir
    FileUtils.mkdir_p(data_dir)
  end

  def projects_index_path
    File.join(data_dir, PROJECTS_FILE)
  end

  def projects_root_path
    File.join(data_dir, PROJECTS_FOLDER)
  end

  def project_folder(project_id)
    File.join(projects_root_path, safe_id(project_id, 'Projet invalide'))
  end

  def project_eventer_path(project_id)
    File.join(projects_root_path, "#{safe_id(project_id, 'Projet invalide')}.json")
  end

  def events_path(project_id, child_path = '')
    eventer_path(project_id, child_path, '__events__.json')
  end

  def brins_path(project_id)
    File.join(project_folder(project_id), '__brins__.json')
  end

  def persos_path(project_id)
    File.join(project_folder(project_id), '__persos__.json')
  end

  def state_path
    File.join(data_dir, STATE_FILE)
  end

  def read_json(path, fallback)
    return fallback unless File.exist?(path)

    JSON.parse(File.read(path))
  rescue JSON::ParserError
    fallback
  end

  def write_json(path, data)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate(data))
    log("created #{path}")
  end

  def state
    read_json(state_path, { 'projectOrder' => [] })
  end

  def save_state(data)
    write_json(state_path, data)
  end

  def safe_id(value, label = 'Identifiant invalide')
    id = value.to_s.strip
    raise ArgumentError, label unless id.match?(/\A[a-zA-Z0-9_-]+\z/)

    id
  end

  def safe_path(value)
    value.to_s.strip.split('/').reject(&:empty?).map do |part|
      safe_id(part, 'Chemin invalide')
    end
  end

  def log(message)
    warn("[data] #{message}")
  end

  private

  def eventer_path(project_id, child_path, filename)
    parts = safe_path(child_path)

    return File.join(project_folder(project_id), filename) if parts.empty?

    File.join(project_folder(project_id), *parts, filename)
  end
end
