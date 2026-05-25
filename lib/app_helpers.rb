module AppHelpers
  def data_store
    @data_store ||= DataStore.new(DATA_DIR)
  end

  def eventer_store
    @eventer_store ||= EventerStore.new(data_store)
  end

  def project_store
    @project_store ||= ProjectStore.new(data_store, eventer_store)
  end

  def read_json_payload
    request.body.rewind
    body = request.body.read
    body.empty? ? {} : JSON.parse(body)
  rescue JSON::ParserError
    {}
  end
end
