require 'time'

class ProjectStore
  def initialize(store, eventer_store)
    @store = store
    @eventer_store = eventer_store
  end

  def projects
    project_ids.map do |id|
      eventer = @eventer_store.load(id)

      {
        id: id,
        scale: eventer['scale'].to_s.empty? ? 'project' : eventer['scale'],
        title: eventer['title'].to_s.empty? ? id : eventer['title'],
        active: eventer['active'] != false
      }
    end.select { |project| project[:active] }
  end

  def create(raw_name)
    base = raw_name.strip.empty? ? "project-#{Time.now.to_i}" : raw_name.strip
    id = available_id(base)

    eventer = {
      id: id,
      scale: 'project',
      title: id,
      nature: 'roman',
      active: true,
      options: { colorizeEventsWithFirstBrin: true },
      events: [],
      brins: [],
      persos: [],
      project_id: nil,
      lasts_id: { event: 0, brin: 0, perso: 0 }
    }

    @store.write_json(@store.project_eventer_path(id), eventer)
    save_project_ids(project_ids + [id])

    {
      id: id,
      scale: 'project',
      title: id,
      active: true
    }
  end

  def update(project_id, payload)
    id = @store.safe_id(project_id, 'Projet invalide')
    data = @eventer_store.load(id)

    data['active'] = payload['active'] == true if payload.key?('active')
    data['title'] = payload['title'].to_s if payload.key?('title')

    @eventer_store.save(id, '', data)

    {
      id: id,
      scale: data['scale'].to_s.empty? ? 'project' : data['scale'],
      title: data['title'].to_s.empty? ? id : data['title'],
      active: data['active'] != false
    }
  end

  def archive(project_id)
    update(project_id, { 'active' => false })
  end

  def reorder(order)
    known_ids = root_project_ids
    ids = order.map { |id| @store.safe_id(id.to_s.sub(/\.json$/, ''), 'Projet invalide') }
    ordered_known_ids = ids.select { |id| known_ids.include?(id) }
    missing_ids = known_ids.reject { |id| ordered_known_ids.include?(id) }

    save_project_ids(ordered_known_ids + missing_ids)
  end

  private

  def project_ids
    ordered_ids(root_project_ids)
  end

  def root_project_ids
    root = @store.read_json(@store.projects_index_path, empty_root_eventer)
    root.is_a?(Array) ? root : root.fetch('events', [])
  end

  def save_project_ids(ids)
    root = @store.read_json(@store.projects_index_path, empty_root_eventer)
    root = empty_root_eventer if root.is_a?(Array)
    root['events'] = ids.uniq
    root['updated_at'] = Time.now.iso8601
    @store.write_json(@store.projects_index_path, root)

    state = @store.state
    state['projectOrder'] = ids.uniq
    @store.save_state(state)
  end

  def empty_root_eventer
    {
      'id' => '__projects__',
      'scale' => 'eventer',
      'events' => [],
      'brins' => [],
      'persos' => [],
      'project_id' => nil,
      'active' => true,
      'lasts_id' => { 'event' => 0, 'brin' => 0, 'perso' => 0 }
    }
  end

  def ordered_ids(ids)
    order = @store.state['projectOrder'] || []
    known_order = order.select { |id| ids.include?(id) }
    unordered = ids.reject { |id| known_order.include?(id) }.sort

    known_order + unordered
  end

  def available_id(raw_id)
    base = @store.safe_id(raw_id, 'Projet invalide')
    id = base
    index = 1

    while project_ids.include?(id)
      index += 1
      id = @store.safe_id("#{base}-#{index}", 'Projet invalide')
    end

    id
  end
end
