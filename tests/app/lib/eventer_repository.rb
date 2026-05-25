require 'fileutils'
require 'time'

class EventerRepository
  def initialize(paths, store)
    @paths = paths
    @store = store
  end

  def load(eventer_id)
    id = @paths.safe_id(eventer_id)
    eventer = @store.read(@paths.eventer_file(id), default_eventer(id))

    normalize_eventer(id, eventer)
  end

  def save(eventer_id, data)
    id = @paths.safe_id(eventer_id)
    eventer = normalize_eventer(id, data.dup)

    eventer.delete('items')
    eventer.delete('brins_data')
    eventer.delete('persos_data')
    eventer['updated_at'] = timestamp

    FileUtils.mkdir_p(@paths.eventer_folder(id))
    @store.write(@paths.eventer_file(id), eventer)
  end

  def list_events(eventer_id)
    @store.read(@paths.events_file(eventer_id), [])
  end

  def list_brins(eventer_id)
    @store.read(@paths.brins_file(eventer_id), [])
  end

  def list_persos(eventer_id)
    @store.read(@paths.persos_file(eventer_id), [])
  end

  def save_events(eventer_id, events)
    @store.write(@paths.events_file(eventer_id), events)
  end

  def save_brins(eventer_id, brins)
    @store.write(@paths.brins_file(eventer_id), brins)
  end

  def save_persos(eventer_id, persos)
    @store.write(@paths.persos_file(eventer_id), persos)
  end

  def ensure_child(parent_id, child_id, title = '')
    id = @paths.safe_id(child_id, 'Enfant invalide')
    return { id: id } if File.exist?(@paths.eventer_file(id))

    child = {
      id: id,
      scale: 'eventer',
      title: title,
      events: [],
      brins: [],
      persos: [],
      project_id: parent_id,
      active: true,
      created_at: timestamp,
      updated_at: timestamp,
      lasts_id: { event: 0, brin: 0, perso: 0 }
    }

    @store.write(@paths.eventer_file(id), child)
    FileUtils.mkdir_p(@paths.eventer_folder(id))
    save_events(id, [])

    { id: id }
  end

  def breadcrumbs(eventer_id)
    eventer = load(eventer_id)

    [
      {
        label: eventer['title'].to_s.empty? ? eventer_id : eventer['title'].to_s,
        path: ''
      }
    ]
  end

  private

  def normalize_eventer(id, eventer)
    eventer = stringify_keys(eventer)

    eventer['id'] = id
    eventer['scale'] ||= id == EventerPaths::ROOT_EVENTER_ID ? 'eventer' : 'project'
    eventer['events'] ||= []
    eventer['brins'] ||= []
    eventer['persos'] ||= []
    eventer['active'] = true unless eventer.key?('active')
    eventer['created_at'] ||= timestamp
    eventer['updated_at'] ||= timestamp
    eventer['lasts_id'] ||= { 'event' => 0, 'brin' => 0, 'perso' => 0 }

    eventer
  end

  def default_eventer(id)
    {
      'id' => id,
      'scale' => id == EventerPaths::ROOT_EVENTER_ID ? 'eventer' : 'project',
      'events' => [],
      'brins' => [],
      'persos' => [],
      'active' => true,
      'created_at' => timestamp,
      'updated_at' => timestamp,
      'lasts_id' => { 'event' => 0, 'brin' => 0, 'perso' => 0 }
    }
  end

  def stringify_keys(value)
    case value
    when Hash
      value.each_with_object({}) { |(key, item), hash| hash[key.to_s] = stringify_keys(item) }
    when Array
      value.map { |item| stringify_keys(item) }
    else
      value
    end
  end

  def timestamp
    Time.now.iso8601
  end
end
