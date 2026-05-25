class EventerStore
  def initialize(store)
    @store = store
  end

  def load(project_id, child_path = '')
    eventer = @store.read_json(
      eventer_file(project_id, child_path),
      empty_eventer(project_id)
    )

    eventer['events'] ||= []
    eventer['brins'] ||= []
    eventer['persos'] ||= []
    eventer
  end

  def load_with_navigation(project_id, child_path = '')
    path = @store.safe_path(child_path).join('/')
    data = load(project_id, path)

    data.merge(
      'project' => project_id,
      'path' => path,
      'parentPath' => parent_path(path),
      'breadcrumbs' => breadcrumbs(project_id, path)
    )
  end

  def save(project_id, child_path, data)
    @store.write_json(eventer_file(project_id, child_path), normalize(data))
  end

  def ensure_child(project_id, parent_path, event_id, title)
    safe_event_id = @store.safe_id(event_id, 'Enfant invalide')
    parts = @store.safe_path(parent_path) + [safe_event_id]
    child_path = parts.join('/')

    return child_path if File.exist?(eventer_file(project_id, child_path))

    save(project_id, child_path, child_eventer(project_id, safe_event_id, title))
    child_path
  end

  private

  def eventer_file(project_id, child_path)
    parts = @store.safe_path(child_path)

    return @store.project_eventer_path(project_id) if parts.empty?

    File.join(@store.project_folder(project_id), *parts, '__events__.json')
  end

  def normalize(data)
    data['events'] ||= []
    data['brins'] ||= []
    data['persos'] ||= []
    data
  end

  def empty_eventer(project_id)
    {
      'id' => project_id,
      'scale' => 'eventer',
      'events' => [],
      'brins' => [],
      'persos' => []
    }
  end

  def child_eventer(project_id, event_id, title)
    {
      id: event_id,
      scale: 'eventer',
      title: title,
      events: [],
      brins: [],
      persos: [],
      project_id: project_id,
      lasts_id: { event: 0, brin: 0, perso: 0 }
    }
  end

  def breadcrumbs(project_id, child_path)
    parts = @store.safe_path(child_path)
    crumbs = []

    root = load(project_id, '')
    crumbs << {
      label: root['title'].to_s.empty? ? project_id : root['title'],
      path: ''
    }

    parts.each_with_index do |_part, index|
      current_path = parts[0..index].join('/')
      data = load(project_id, current_path)
      crumbs << {
        label: data['title'].to_s.empty? ? parts[index] : data['title'],
        path: current_path
      }
    end

    crumbs
  end

  def parent_path(path)
    parts = @store.safe_path(path)
    parts[0..-2]&.join('/').to_s
  end
end
