require_relative './json_file'
require_relative './logger'

module Eventer
  class Bootstrap
    DEMO_PROJECT_ID = 'demo'
    DEMO_PROJECT_TITLE = 'Projet de démonstration'

    def initialize(paths)
      @paths = paths
    end

    def ensure_initial_data!
      Logger.bootstrap("vérification #{@paths.data_dir}")

      if Dir.exist?(@paths.data_dir)
        Logger.bootstrap('dossier data présent')
        return
      end

      Logger.bootstrap('dossier data absent : création')
      create_demo_project
      Logger.bootstrap('dossier data créé')
    end

    private

    def create_demo_project
      JsonFile.write(@paths.projects_index_file, [DEMO_PROJECT_ID])
      JsonFile.write(@paths.project_eventer_file(DEMO_PROJECT_ID), demo_project_eventer)
      JsonFile.write(@paths.events_file(DEMO_PROJECT_ID), demo_events)
      JsonFile.write(@paths.brins_file(DEMO_PROJECT_ID), demo_brins)
      JsonFile.write(@paths.persos_file(DEMO_PROJECT_ID), demo_persos)
    end

    def demo_project_eventer
      {
        'id' => DEMO_PROJECT_ID,
        'scale' => 'project',
        'title' => DEMO_PROJECT_TITLE,
        'nature' => 'roman',
        'events' => ['e1'],
        'brins' => ['b1'],
        'persos' => ['p1'],
        'project_id' => nil,
        'active' => true,
        'options' => { 'colorizeEventsWithFirstBrin' => true },
        'lasts_id' => { 'event' => 1, 'brin' => 1, 'perso' => 1 }
      }
    end

    def demo_events
      [
        {
          'id' => 'e1',
          'title' => 'Bienvenue dans Eventer2 — évènement fictif modifiable.',
          'brins' => ['b1'],
          'persos' => ['p1'],
          'type' => ['act'],
          'nature' => [],
          'duration' => nil,
          'file' => '',
          'state' => 1,
          'child' => false
        }
      ]
    end

    def demo_brins
      [
        {
          'id' => 'b1',
          'nom' => 'Brin principal fictif',
          'badge' => 'PRI',
          'color' => '#578ddb',
          'type' => 'mint',
          'persos' => ['p1'],
          'file' => ''
        }
      ]
    end

    def demo_persos
      [
        {
          'id' => 'p1',
          'badge' => 'GD',
          'avatar' => '🙂',
          'pseudo' => 'Guide',
          'patronyme' => 'Guide Démo',
          'fonctions' => ['ment'],
          'file' => ''
        }
      ]
    end
  end
end
