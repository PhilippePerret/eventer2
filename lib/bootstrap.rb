require 'json'
require 'fileutils'

class Bootstrap

  DATA_FOLDER = File.join(Dir.pwd, 'data')

  def self.ensure_initial_data!
    new.ensure_initial_data!
  end

  def ensure_initial_data!
    return if File.exist?(DATA_FOLDER)

    create_base_structure
    create_demo_project
  end

  private

  def create_base_structure
    FileUtils.mkdir_p(projects_folder)

    write_json(
      File.join(DATA_FOLDER, '__projects__.json'),
      ['demo']
    )
  end

  def create_demo_project
    FileUtils.mkdir_p(demo_folder)

    write_json(
      File.join(demo_folder, '__events__.json'),
      [
        {
          id: 'e1',
          title: 'Bienvenue dans Eventer2',
          brins: ['b1'],
          persos: ['p1'],
          state: 1
        }
      ]
    )

    write_json(
      File.join(demo_folder, '__brins__.json'),
      [
        {
          id: 'b1',
          nom: 'Brin principal',
          badge: 'PRI',
          color: '#578ddb',
          type: 'mint',
          persos: ['p1']
        }
      ]
    )

    write_json(
      File.join(demo_folder, '__persos__.json'),
      [
        {
          id: 'p1',
          badge: 'GD',
          avatar: '🙂',
          pseudo: 'Guide',
          patronyme: 'Guide Démo',
          fonctions: ['ment']
        }
      ]
    )
  end

  def projects_folder
    File.join(DATA_FOLDER, '__projects__')
  end

  def demo_folder
    File.join(projects_folder, 'demo')
  end

  def write_json(path, data)
    File.write(
      path,
      JSON.pretty_generate(data)
    )
  end

end
