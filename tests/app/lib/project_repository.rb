require 'fileutils'
require 'time'

class ProjectRepository
  def initialize(paths, store, eventers, state)
    @paths = paths
    @store = store
    @eventers = eventers
    @state = state
  end

  def all
    ordered_project_ids.map do |id|
      eventer = @eventers.load(id)

      {
        id: id,
        file: "#{id}.json",
        title: eventer['title'].to_s.empty? ? id : eventer['title'].to_s,
        active: eventer['active'] != false,
        scale: eventer['scale']
      }
    end.select { |project| project[:active] }
  end

  def create(raw_title)
    id = available_id(raw_title)
    now = Time.now.iso8601

    eventer = {
      id: id,
      scale: 'project',
      title: raw_title.to_s.strip.empty? ? id : raw_title.to_s.strip,
      nature: 'roman',
      events: [],
      brins: [],
      persos: [],
      project_id: nil,
      active: true,
      options: { colorizeEventsWithFirstBrin: true },
      created_at: now,
      updated_at: now,
      lasts_id: { event: 0, brin: 0, perso: 0 }
    }

    @eventers.save(id, eventer)
    FileUtils.mkdir_p(@paths.eventer_folder(id))
    @eventers.save_events(id, [])
    @eventers.save_brins(id, [])
    @eventers.save_persos(id, [])

    root = @eventers.load(EventerPaths::ROOT_EVENTER_ID)
    root['events'] << id unless root['events'].include?(id)
    @eventers.save(EventerPaths::ROOT_EVENTER_ID, root)

    update_order(root['events'])

    {
      id: id,
      file: "#{id}.json",
      title: eventer[:title],
      active: true,
      scale: 'project'
    }
  end

  def update(id, payload)
    project_id = @paths.safe_id(id, 'Projet invalide')
    eventer = @eventers.load(project_id)

    eventer['title'] = payload['title'].to_s if payload.key?('title')
    eventer['active'] = payload['active'] == true if payload.key?('active')

    @eventers.save(project_id, eventer)

    {
      id: project_id,
      file: "#{project_id}.json",
      title: eventer['title'].to_s.empty? ? project_id : eventer['title'].to_s,
      active: eventer['active'] != false,
      scale: eventer['scale']
    }
  end

  def archive(id)
    update(id, { 'active' => false })
  end

  def reorder(order)
    ids = order.map { |id| @paths.safe_id(id.to_s.sub(/\.json$/, ''), 'Projet invalide') }

    root = @eventers.load(EventerPaths::ROOT_EVENTER_ID)
    known = root['events']
    root['events'] = ids.select { |id| known.include?(id) } + known.reject { |id| ids.include?(id) }

    @eventers.save(EventerPaths::ROOT_EVENTER_ID, root)
    update_order(root['events'])
  end

  private

  def ordered_project_ids
    root = @eventers.load(EventerPaths::ROOT_EVENTER_ID)
    ids = root['events'] || []
    order = @state.load['projectOrder'] || []

    ordered = order.select { |id| ids.include?(id) }
    unordered = ids.reject { |id| ordered.include?(id) }

    ordered + unordered
  end

  def update_order(ids)
    state = @state.load
    state['projectOrder'] = ids
    @state.save(state)
  end

  def available_id(raw_title)
    base = raw_title.to_s.strip.downcase.gsub(/[^a-z0-9_-]+/, '-').gsub(/\A-+|-+\z/, '')
    base = "project-#{Time.now.to_i}" if base.empty?

    id = @paths.safe_id(base, 'Projet invalide')
    index = 1

    while File.exist?(@paths.eventer_file(id))
      index += 1
      id = @paths.safe_id("#{base}-#{index}", 'Projet invalide')
    end

    id
  end
end
