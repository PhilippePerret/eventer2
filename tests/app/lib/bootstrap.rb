require 'json'
require 'fileutils'

class Bootstrap
  DEMO_PROJECT_ID = 'demo'

  def self.ensure_initial_data!(data_dir)
    new(data_dir).ensure_initial_data!
  end

  def initialize(data_dir)
    @data_dir = data_dir
  end

  def ensure_initial_data!
    log("check data folder: #{@data_dir}")

    if Dir.exist?(@data_dir)
      log('data folder already exists')
      return
    end

    log('data folder missing, creating initial demo project')
    create_initial_data!
    log('initial demo project created')
  end

  private

  def create_initial_data!
    FileUtils.mkdir_p(projects_root)
    FileUtils.mkdir_p(demo_project_folder)

    write_json(projects_file, [DEMO_PROJECT_ID])

    write_json(
      legacy_project_file,
      {
        id: DEMO_PROJECT_ID,
        scale: 'project',
        title: 'Projet de démonstration',
        nature: 'roman',
        active: true,
        options: { colorizeEventsWithFirstBrin: true },
        events: ['e1'],
        brins: ['b1'],
        persos: ['p1'],
        lasts_id: { event: 1, brin: 1, perso: 1 },
        evenements: [
          {
            id: 'e1',
            text: 'Bienvenue dans Eventer2 — modifiez ce projet de démonstration.',
            title: 'Bienvenue dans Eventer2 — modifiez ce projet de démonstration.',
            brins: ['b1'],
            persos: ['p1'],
            checked: false,
            state: 1,
            type: ['act'],
            duration: nil,
            file: '',
            child: ''
          }
        ],
        personnages: [
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
      }
    )

    write_json(
      File.join(demo_project_folder, '__events__.json'),
      [
        {
          id: 'e1',
          title: 'Bienvenue dans Eventer2 — modifiez cet évènement.',
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
    )

    write_json(
      File.join(demo_project_folder, '__brins__.json'),
      [
        {
          id: 'b1',
          nom: 'Brin principal de démonstration',
          badge: 'PRI',
          color: '#578ddb',
          type: 'mint',
          persos: ['p1'],
          file: ''
        }
      ]
    )

    write_json(
      File.join(demo_project_folder, '__persos__.json'),
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
    )
  end

  def write_json(path, data)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate(data))
    log("created #{path}")
  end

  def projects_file
    File.join(@data_dir, '__projects__.json')
  end

  def projects_root
    File.join(@data_dir, '__projects__')
  end

  def demo_project_folder
    File.join(projects_root, DEMO_PROJECT_ID)
  end

  def legacy_project_file
    File.join(@data_dir, "#{DEMO_PROJECT_ID}.json")
  end

  def log(message)
    warn("[bootstrap] #{message}")
  end
end
