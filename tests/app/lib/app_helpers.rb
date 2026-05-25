module AppHelpers
  def json_payload
    request.body.rewind
    body = request.body.read
    body.empty? ? {} : JSON.parse(body)
  rescue JSON::ParserError
    {}
  end

  def eventer_paths
    @eventer_paths ||= EventerPaths.new(DATA_DIR)
  end

  def json_store
    @json_store ||= JsonStore.new
  end

  def state_store
    @state_store ||= StateStore.new(eventer_paths, json_store)
  end

  def eventer_repository
    @eventer_repository ||= EventerRepository.new(eventer_paths, json_store)
  end

  def project_repository
    @project_repository ||= ProjectRepository.new(
      eventer_paths,
      json_store,
      eventer_repository,
      state_store
    )
  end
end
