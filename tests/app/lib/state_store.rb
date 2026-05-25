class StateStore
  def initialize(paths, store)
    @paths = paths
    @store = store
  end

  def load
    @store.read(@paths.state_file, { 'projectOrder' => [] })
  end

  def save(state)
    @store.write(@paths.state_file, state)
  end
end
