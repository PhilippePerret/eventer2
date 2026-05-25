require 'json'
require 'fileutils'

class Bootstrap
  DEMO_PROJECT_ID = 'demo'
  DEMO_PROJECT_TITLE = 'Projet de démonstration'

  def self.ensure_initial_data!(data_dir)
    new(data_dir).ensure_initial_data!
  end

  def initialize(data_dir)
    @data_dir = data_dir
  end

  def ensure_initial_data!
    log("vérification dossier data : #{@data_dir}")

    if Dir.exist?(@data_dir)
      log('dossier data présent : aucun bootstrap nécessaire')
      return
    end

    log('dossier data absent : création du socle initial')
    create_initial_data
    log('socle initial créé')
  end

  private

  def create_initial_data
    FileUtils.mkdir_p(@data_dir)
    FileUtils.mkdir_p(canonical_project_dir)
    FileUtils.mkdir_p(legacy_project_dir)

    write_json(projects_index_file, [DEMO_PROJECT_ID])
    write_json(legacy_project_file, legacy_project_data)
    write_json(canonical_events_file, demo_events)
    write_json(canonical_brins_file, demo_brins)
    write_json(canonical_persos_file, demo_persos)
  end

  def legacy_project_data
    {
      title: DEMO_PROJECT_TITLE,
      active: true,
      options: { colorizeEventsWithFirstBrin: true },
      personnages: demo_persos,
      brins: demo_brins,
      evenements: [
        {
          id: 'e1',
          text: 'Bienvenue dans Eventer2 — projet fictif modifiable.',
          brins: ['b1'],
          persos: ['p1'],
          checked: false,
          state: 'ébauche',
          type: 'act',
          duration: nil,
          file: '',
          child: ''
        }
      ]
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

  def projects_index_file
    File.join(@data_dir, '__projects__.json')
  end

  def canonical_project_dir
    File.join(@data_dir, '__projects__', DEMO_PROJECT_ID)
  end

  def legacy_project_dir
    File.join(@data_dir, DEMO_PROJECT_ID)
  end

  def legacy_project_file
    File.join(@data_dir, "#{DEMO_PROJECT_ID}.json")
  end

  def canonical_events_file
    File.join(canonical_project_dir, '__events__.json')
  end

  def canonical_brins_file
    File.join(canonical_project_dir, '__brins__.json')
  end

  def canonical_persos_file
    File.join(canonical_project_dir, '__persos__.json')
  end

  def write_json(path, data)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate(data))
    log("créé : #{path}")
  end

  def log(message)
    warn("[bootstrap] #{message}")
  end
end
