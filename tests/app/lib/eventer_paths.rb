class EventerPaths
  ROOT_EVENTER_ID = '__projects__'

  def initialize(data_dir)
    @data_dir = data_dir
  end

  def data_dir
    @data_dir
  end

  def eventer_file(eventer_id)
    id = safe_id(eventer_id)

    return File.join(@data_dir, '__projects__.json') if id == ROOT_EVENTER_ID

    File.join(root_eventer_folder, "#{id}.json")
  end

  def eventer_folder(eventer_id)
    id = safe_id(eventer_id)

    return root_eventer_folder if id == ROOT_EVENTER_ID

    File.join(root_eventer_folder, id)
  end

  def root_eventer_folder
    File.join(@data_dir, '__projects__')
  end

  def events_file(eventer_id)
    File.join(eventer_folder(eventer_id), '__events__.json')
  end

  def brins_file(eventer_id)
    File.join(eventer_folder(eventer_id), '__brins__.json')
  end

  def persos_file(eventer_id)
    File.join(eventer_folder(eventer_id), '__persos__.json')
  end

  def state_file
    File.join(@data_dir, '__state__.json')
  end

  def safe_id(value, label = 'Identifiant invalide')
    id = value.to_s.strip

    raise ArgumentError, label unless id.match?(/\A[a-zA-Z0-9_-]+\z/)

    id
  end
end
