require 'fileutils'
require_relative './json_file'
require_relative './sanitizer'
require_relative './bootstrap'

module Eventer
  class ProjectRepository
    def initialize(paths)
      @paths = paths
    end

    def all
      project_ids.map do |project_id|
        data = JsonFile.read(@paths.project_eventer_file(project_id), {})
        next if data['active'] == false

        {
          id: project_id,
          file: "#{project_id}.json",
          title: data['title'].to_s.empty? ? project_id : data['title'].to_s
        }
      end.compact
    end

    def create(requested_id)
      base = requested_id.to_s.strip
      base = "project-#{Time.now.to_i}" if base.empty?

      project_id = unique_project_id(base)

      JsonFile.write(@paths.project_eventer_file(project_id), blank_project_eventer(project_id))
      JsonFile.write(@paths.events_file(project_id), [])
      JsonFile.write(@paths.brins_file(project_id), [])
      JsonFile.write(@paths.persos_file(project_id), [])

      ids = project_ids
      ids << project_id
      JsonFile.write(@paths.projects_index_file, ids)

      {
        id: project_id,
        file: "#{project_id}.json",
        title: project_id
      }
    end

    def update(project_id, payload)
      id = Sanitizer.id(project_id, 'Projet invalide')
      data = JsonFile.read(@paths.project_eventer_file(id), blank_project_eventer(id))

      data['title'] = payload['title'].to_s if payload.key?('title')
      data['active'] = payload['active'] == true if payload.key?('active')

      JsonFile.write(@paths.project_eventer_file(id), data)

      {
        id: id,
        file: "#{id}.json",
        title: data['title'].to_s.empty? ? id : data['title'].to_s,
        active: data['active'] != false
      }
    end

    def deactivate(project_id)
      update(project_id, 'active' => false)
    end

    def reorder(order)
      cleaned = order.map { |name| Sanitizer.id(name.to_s.sub(/\.json\z/, ''), 'Projet invalide') }
      known = project_ids
      JsonFile.write(@paths.projects_index_file, cleaned.select { |id| known.include?(id) })
    end

    private

    def project_ids
      JsonFile.read(@paths.projects_index_file, [])
    end

    def unique_project_id(base)
      root = Sanitizer.id(base, 'Projet invalide')
      candidate = root
      index = 1

      while project_ids.include?(candidate) || Dir.exist?(@paths.project_dir(candidate))
        index += 1
        candidate = Sanitizer.id("#{root}-#{index}", 'Projet invalide')
      end

      candidate
    end

    def blank_project_eventer(project_id)
      {
        'id' => project_id,
        'scale' => 'project',
        'title' => project_id,
        'nature' => 'roman',
        'events' => [],
        'brins' => [],
        'persos' => [],
        'project_id' => nil,
        'active' => true,
        'options' => { 'colorizeEventsWithFirstBrin' => true },
        'lasts_id' => { 'event' => 0, 'brin' => 0, 'perso' => 0 }
      }
    end
  end
end
