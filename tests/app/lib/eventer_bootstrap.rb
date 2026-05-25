require 'fileutils'
require 'time'

class EventerBootstrap
  DEMO_PROJECT_ID = 'demo'

  def self.ensure_initial_data!(data_dir)
    paths = EventerPaths.new(data_dir)
    store = JsonStore.new
    eventers = EventerRepository.new(paths, store)

    new(paths, store, eventers).ensure_initial_data!
  end

  def initialize(paths, store, eventers)
    @paths = paths
    @store = store
    @eventers = eventers
  end

  def ensure_initial_data!
    return if complete?

    warn("[bootstrap] création du socle eventer")
    create_initial_data
  end

  private

  def complete?
    File.exist?(@paths.eventer_file(EventerPaths::ROOT_EVENTER_ID)) &&
      Dir.exist?(@paths.eventer_folder(EventerPaths::ROOT_EVENTER_ID)) &&
      File.exist?(@paths.eventer_file(DEMO_PROJECT_ID)) &&
      Dir.exist?(@paths.eventer_folder(DEMO_PROJECT_ID)) &&
      File.exist?(@paths.events_file(DEMO_PROJECT_ID)) &&
      File.exist?(@paths.brins_file(DEMO_PROJECT_ID)) &&
      File.exist?(@paths.persos_file(DEMO_PROJECT_ID))
  end

  def create_initial_data
    FileUtils.mkdir_p(@paths.data_dir)
    FileUtils.mkdir_p(@paths.eventer_folder(EventerPaths::ROOT_EVENTER_ID))
    FileUtils.mkdir_p(@paths.eventer_folder(DEMO_PROJECT_ID))

    @store.write(@paths.eventer_file(EventerPaths::ROOT_EVENTER_ID), root_eventer)
    @store.write(@paths.eventer_file(DEMO_PROJECT_ID), demo_project_eventer)
    @eventers.save_events(DEMO_PROJECT_ID, demo_events)
    @eventers.save_brins(DEMO_PROJECT_ID, demo_brins)
    @eventers.save_persos(DEMO_PROJECT_ID, demo_persos)
  end

  def root_eventer
    {
      id: EventerPaths::ROOT_EVENTER_ID,
      scale: 'eventer',
      events: [DEMO_PROJECT_ID],
      brins: [],
      persos: [],
      project_id: nil,
      active: true,
      created_at: timestamp,
      updated_at: timestamp,
      lasts_id: { event: 1, brin: 0, perso: 0 }
    }
  end

  def demo_project_eventer
    {
      id: DEMO_PROJECT_ID,
      scale: 'project',
      title: 'Projet de démonstration',
      nature: 'roman',
      events: ['e1'],
      brins: ['b1'],
      persos: ['p1'],
      project_id: nil,
      active: true,
      options: { colorizeEventsWithFirstBrin: true },
      created_at: timestamp,
      updated_at: timestamp,
      lasts_id: { event: 1, brin: 1, perso: 1 }
    }
  end

  def demo_events
    [
      {
        id: 'e1',
        title: 'Bienvenue dans Eventer2 — évènement fictif modifiable.',
        brins: ['b1'],
        persos: ['p1'],
        type: ['act'],
        nature: [],
        duration: nil,
        file: '',
        state: 1,
        child: false
      }
    ]
  end

  def demo_brins
    [
      {
        id: 'b1',
        nom: 'Brin principal fictif',
        badge: 'PRI',
        color: '#578ddb',
        type: 'mint',
        persos: ['p1'],
        file: ''
      }
    ]
  end

  def demo_persos
    [
      {
        id: 'p1',
        badge: 'GD',
        avatar: '🙂',
        pseudo: 'Guide',
        patronyme: 'Guide Démo',
        fonctions: ['ment'],
        file: ''
      }
    ]
  end

  def timestamp
    Time.now.iso8601
  end
end
