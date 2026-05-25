require 'sinatra'
require 'json'
require 'fileutils'
require 'securerandom'
require_relative './lib/bootstrap'

set :public_folder, 'public'

DATA_DIR = File.expand_path('data', __dir__)
DEFAULT_PROJECT = '__e2__'
STATE_FILE = File.join(DATA_DIR, '__state__.json')

helpers do

  def load_state
    return { 'projectOrder' => [] } unless File.exist?(STATE_FILE)

    JSON.parse(File.read(STATE_FILE))
  rescue StandardError
    { 'projectOrder' => [] }
  end

  def save_state(state)
    FileUtils.mkdir_p(DATA_DIR)
    File.write(STATE_FILE, JSON.pretty_generate(state))
  end
  def safe_id(value, label = 'Identifiant invalide')
    id = value.to_s.strip
    halt 400, { error: label }.to_json unless id.match?(/\A[a-zA-Z0-9_-]+\z/)
    id
  end

  def safe_project_name(name)
    safe_id(name, 'Projet invalide')
  end

  def safe_child_path(path)
    raw = path.to_s.strip
    return [] if raw.empty?

    raw.split('/').map { |part| safe_id(part, 'Chemin invalide') }
  end

  def project_root_file(project)
    File.join(DATA_DIR, "#{safe_project_name(project)}.json")
  end

  def project_root_dir(project)
    File.join(DATA_DIR, safe_project_name(project))
  end

  def eventer_file(project, child_path = [])
    parts = safe_child_path(child_path.is_a?(Array) ? child_path.join('/') : child_path)

    if parts.empty?
      project_root_file(project)
    else
      File.join(project_root_dir(project), *parts[0..-2], "#{parts[-1]}.json")
    end
  end

  def eventer_child_dir(project, child_path = [])
    parts = safe_child_path(child_path.is_a?(Array) ? child_path.join('/') : child_path)

    if parts.empty?
      project_root_dir(project)
    else
      File.join(project_root_dir(project), *parts)
    end
  end

  def project_names
    return [] unless Dir.exist?(DATA_DIR)

    names = Dir.children(DATA_DIR)
               .select { |entry| entry.end_with?('.json') && File.file?(File.join(DATA_DIR, entry)) }
               .reject { |entry| ['__state__.json', '__projects__.json'].include?(entry) }
               .map { |entry| File.basename(entry, '.json') }

    state = load_state
    order = state['projectOrder'] || []

    ordered = order.select { |name| names.include?(name) }
    unordered = (names - ordered).sort

    (ordered + unordered).select do |name|
      begin
        data = load_eventer(name)
        data['active'] != false
      rescue StandardError
        false
      end
    end
  end

  def default_data(title = '')
    {
      title: title,
      active: true,
      options: { colorizeEventsWithFirstBrin: true },
      personnages: [],
      brins: [],
      evenements: []
    }
  end

  def default_child_data(title = '')
    data = default_data(title)
    data[:evenements] = [
      {
        id: SecureRandom.uuid,
        text: '',
        brins: [],
        persos: [],
        checked: false,
        state: '---',
        type: '',
        duration: nil,
        file: '',
        child: ''
      }
    ]
    data
  end

  def ensure_eventer_has_event(data)
  return data if data['active'] == false || data[:active] == false
    data['evenements'] ||= data[:evenements] || []
    return data unless data['evenements'].empty?

    data['evenements'] << {
      'id' => SecureRandom.uuid,
      'text' => '',
      'brins' => [],
      'persos' => [],
      'checked' => false,
      'state' => '---',
      'type' => '',
      'duration' => nil,
      'file' => '',
      'child' => ''
    }
    data
  end

  def load_eventer(project, child_path = [])
    path = eventer_file(project, child_path)
    return default_data unless File.exist?(path)

    JSON.parse(File.read(path))
  end

  def save_eventer(project, child_path, data)
    FileUtils.mkdir_p(DATA_DIR)
    FileUtils.mkdir_p(project_root_dir(project))
    FileUtils.mkdir_p(File.dirname(eventer_file(project, child_path)))
    FileUtils.mkdir_p(eventer_child_dir(project, child_path))

    File.write(
      eventer_file(project, child_path),
      JSON.pretty_generate(data)
    )
  end

  def ensure_child_eventer(project, parent_path, child_id, title = '')
    parent_parts = safe_child_path(parent_path)
    child = safe_id(child_id, 'Enfant invalide')
    child_parts = parent_parts + [child]
    child_file = eventer_file(project, child_parts)

    if File.exist?(child_file)
      child_data = ensure_eventer_has_event(load_eventer(project, child_parts))
      save_eventer(project, child_parts, child_data)
    else
      save_eventer(project, child_parts, default_child_data(title))
    end

    FileUtils.mkdir_p(eventer_child_dir(project, child_parts))
    child_parts.join('/')
  end



  def child_has_real_events?(project, child_path)
    data = load_eventer(project, child_path)
    events = data['evenements'] || data[:evenements] || []
    events.any? do |event|
      text = event['text'] || event[:text] || ''
      text.to_s.strip != ''
    end
  rescue StandardError
    false
  end

  def annotate_child_flags(project, child_path, data)
    events = data['evenements'] || data[:evenements] || []
    events.each do |event|
      child = (event['child'] || event[:child] || '').to_s
      event['childHasEvents'] = !child.empty? && child_has_real_events?(project, child)
    end
    data
  end

  def breadcrumbs_for(project, child_path = [])
    parts = safe_child_path(child_path.is_a?(Array) ? child_path.join('/') : child_path)
    crumbs = []

    root_data = load_eventer(project)
    crumbs << {
      label: root_data['title'].to_s.empty? ? project : root_data['title'].to_s,
      path: ''
    }

    parts.each_with_index do |_part, index|
      path_parts = parts[0..index]
      data = load_eventer(project, path_parts)
      label = data['title'].to_s.empty? ? path_parts[-1] : data['title'].to_s
      crumbs << { label: label, path: path_parts.join('/') }
    end

    crumbs
  end
end

Bootstrap.ensure_initial_data!(DATA_DIR)

before do
  content_type :json if request.path_info.start_with?('/projects', '/events', '/child')
end

get '/' do
  content_type :html
  send_file File.join(settings.public_folder, 'index.html')
end

get '/projects' do
  projects = project_names.map do |name|
    data = load_eventer(name)
    {
      id: name,
      file: "#{name}.json",
      title: data['title'].to_s.empty? ? name : data['title'].to_s
    }
  end

  projects.to_json
end




post '/projects' do
  content_type :json

  request.body.rewind
  payload = JSON.parse(request.body.read) rescue {}

  base = payload['name'].to_s.strip
  base = "project-#{Time.now.to_i}" if base.empty?
  project = safe_project_name(base)

  index = 1
  while File.exist?(eventer_file(project, ''))
    index += 1
    project = safe_project_name("#{base}-#{index}")
  end

  data = default_data(project)
  data['active'] = true
  data[:active] = true if data.respond_to?(:key?) && data.key?(:active)

  save_eventer(project, '', data)
  FileUtils.mkdir_p(project_root_dir(project)) if respond_to?(:project_root_dir)

  state = load_state
  order = state['projectOrder'] || []
  order << project unless order.include?(project)
  state['projectOrder'] = order
  save_state(state)

  { status: 'ok', project: { id: project, file: "#{project}.json", title: project }, filename: "#{project}.json" }.to_json
end




patch '/projects/:project' do
  content_type :json

  project = safe_project_name(params[:project])
  request.body.rewind
  payload = JSON.parse(request.body.read) rescue {}

  data = load_eventer(project, '')

  if payload.key?('active')
    data['active'] = payload['active'] == true
  end

  if payload.key?('title')
    data['title'] = payload['title'].to_s
  end

  save_eventer(project, '', data)

  {
    status: 'ok',
    project: {
      id: project,
      file: "#{project}.json",
      title: data['title'].to_s.empty? ? project : data['title'].to_s,
      active: data['active'] != false
    }
  }.to_json
end

delete '/projects/:project' do
  content_type :json

  project = safe_project_name(params[:project])
  path = project_root_file(project)

  halt 404, { error: 'Projet introuvable' }.to_json unless File.exist?(path)

  data = JSON.parse(File.read(path))
  data['active'] = false

  File.write(path, JSON.pretty_generate(data))

  { status: 'ok', project: project, active: false }.to_json
end



post '/projects/reorder' do
  content_type :json

  request.body.rewind
  payload = JSON.parse(request.body.read) rescue {}
  order = payload['order'] || []

  state = load_state
  state['projectOrder'] = order.map { |name| safe_project_name(name.to_s.sub(/\.json$/, '')) }
  save_state(state)

  { status: 'ok' }.to_json
end

post '/projects/order' do
  content_type :json

  request.body.rewind
  payload = JSON.parse(request.body.read) rescue {}
  order = payload['order'] || []

  state = load_state
  state['projectOrder'] = order.map { |name| safe_project_name(name.to_s.sub(/\.json$/, '')) }
  save_state(state)

  { status: 'ok' }.to_json
end



get '/events' do
  project = safe_project_name(params[:project] || DEFAULT_PROJECT)
  child_path = safe_child_path(params[:path] || '')
  data = annotate_child_flags(project, child_path, load_eventer(project, child_path))

  data.merge(
    'project' => project,
    'path' => child_path.join('/'),
    'parentPath' => child_path[0..-2]&.join('/').to_s,
    'breadcrumbs' => breadcrumbs_for(project, child_path)
  ).to_json
end

post '/events' do
  project = safe_project_name(params[:project] || DEFAULT_PROJECT)
  child_path = safe_child_path(params[:path] || '')
  request.body.rewind

  data = JSON.parse(request.body.read)
  save_eventer(project, child_path, data)

  { status: 'ok', project: project, path: child_path.join('/') }.to_json
end

post '/child' do
  project = safe_project_name(params[:project] || DEFAULT_PROJECT)
  parent_path = params[:path] || ''
  request.body.rewind
  payload = JSON.parse(request.body.read)

  child_path = ensure_child_eventer(
    project,
    parent_path,
    payload['eventId'],
    payload['title'].to_s
  )

  { status: 'ok', project: project, path: child_path }.to_json
end
