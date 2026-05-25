require_relative './json_file'
require_relative './sanitizer'

module Eventer
  class EventerRepository
    def initialize(paths)
      @paths = paths
    end

    def load(project_id, child_path = '')
      id = Sanitizer.id(project_id, 'Projet invalide')
      parts = Sanitizer.path(child_path)

      eventer = JsonFile.read(eventer_file(id, parts), blank_eventer(id))
      eventer.merge(
        'project' => id,
        'path' => parts.join('/'),
        'parentPath' => parts[0..-2]&.join('/').to_s,
        'breadcrumbs' => breadcrumbs(id, parts)
      )
    end

    def save(project_id, child_path, data)
      id = Sanitizer.id(project_id, 'Projet invalide')
      parts = Sanitizer.path(child_path)

      JsonFile.write(eventer_file(id, parts), normalize_eventer(data, id))
    end

    def ensure_child(project_id, parent_path, payload)
      id = Sanitizer.id(project_id, 'Projet invalide')
      parent_parts = Sanitizer.path(parent_path)
      child_id = Sanitizer.id(payload['eventId'], 'Enfant invalide')
      child_parts = parent_parts + [child_id]

      unless File.exist?(eventer_file(id, child_parts))
        JsonFile.write(
          eventer_file(id, child_parts),
          blank_eventer(id).merge(
            'id' => child_id,
            'title' => payload['title'].to_s,
            'project_id' => id
          )
        )
      end

      child_parts.join('/')
    end

    private

    def eventer_file(project_id, parts)
      return @paths.project_eventer_file(project_id) if parts.empty?

      @paths.child_eventer_file(project_id, parts)
    end

    def normalize_eventer(data, project_id)
      {
        'id' => data['id'].to_s,
        'scale' => data['scale'] || 'eventer',
        'title' => data['title'].to_s,
        'nature' => data['nature'].to_s,
        'events' => data['events'] || [],
        'brins' => data['brins'] || [],
        'persos' => data['persos'] || [],
        'project_id' => data['project_id'] || project_id,
        'active' => data.key?('active') ? data['active'] : true,
        'options' => data['options'] || {},
        'lasts_id' => data['lasts_id'] || { 'event' => 0, 'brin' => 0, 'perso' => 0 }
      }
    end

    def blank_eventer(project_id)
      {
        'id' => project_id,
        'scale' => 'eventer',
        'title' => '',
        'nature' => '',
        'events' => [],
        'brins' => [],
        'persos' => [],
        'project_id' => project_id,
        'active' => true,
        'options' => { 'colorizeEventsWithFirstBrin' => true },
        'lasts_id' => { 'event' => 0, 'brin' => 0, 'perso' => 0 }
      }
    end

    def breadcrumbs(project_id, parts)
      [
        {
          label: project_title(project_id),
          path: ''
        }
      ] + parts.map.with_index do |part, index|
        selected = parts[0..index]
        eventer = JsonFile.read(eventer_file(project_id, selected), {})
        {
          label: eventer['title'].to_s.empty? ? part : eventer['title'].to_s,
          path: selected.join('/')
        }
      end
    end

    def project_title(project_id)
      data = JsonFile.read(@paths.project_eventer_file(project_id), {})
      data['title'].to_s.empty? ? project_id : data['title'].to_s
    end
  end
end
