require 'sinatra'
require 'json'

require_relative './lib/eventer_paths'
require_relative './lib/json_store'
require_relative './lib/state_store'
require_relative './lib/eventer_repository'
require_relative './lib/project_repository'
require_relative './lib/eventer_bootstrap'
require_relative './lib/app_helpers'

set :public_folder, 'public'

DATA_DIR = File.expand_path('data', __dir__)
DEFAULT_EVENTER = '__projects__'

helpers AppHelpers

before do
  EventerBootstrap.ensure_initial_data!(DATA_DIR)
  content_type :json if request.path_info.start_with?('/projects', '/events', '/child')
end

get '/' do
  content_type :html
  send_file File.join(settings.public_folder, 'index.html')
end

get '/projects' do
  project_repository.all.to_json
end

post '/projects' do
  project = project_repository.create(json_payload['name'].to_s)

  {
    status: 'ok',
    project: project,
    filename: "#{project[:id]}.json"
  }.to_json
end

patch '/projects/:project' do
  project = project_repository.update(params[:project], json_payload)

  {
    status: 'ok',
    project: project
  }.to_json
end

delete '/projects/:project' do
  project_repository.archive(params[:project])

  {
    status: 'ok',
    project: params[:project],
    active: false
  }.to_json
end

post '/projects/reorder' do
  project_repository.reorder(json_payload['order'] || [])

  { status: 'ok' }.to_json
end

post '/projects/order' do
  project_repository.reorder(json_payload['order'] || [])

  { status: 'ok' }.to_json
end

get '/events' do
  eventer_id = params[:project] || params[:eventer] || DEFAULT_EVENTER
  data = eventer_repository.load(eventer_id)

  data.merge(
    'project' => eventer_id,
    'path' => '',
    'parentPath' => '',
    'breadcrumbs' => eventer_repository.breadcrumbs(eventer_id)
  ).to_json
end

post '/events' do
  eventer_id = params[:project] || params[:eventer] || DEFAULT_EVENTER
  eventer_repository.save(eventer_id, json_payload)

  {
    status: 'ok',
    project: eventer_id,
    path: ''
  }.to_json
end

post '/child' do
  payload = json_payload
  parent_id = params[:project] || params[:eventer] || DEFAULT_EVENTER

  child = eventer_repository.ensure_child(
    parent_id,
    payload['eventId'],
    payload['title'].to_s
  )

  {
    status: 'ok',
    project: parent_id,
    path: child[:id]
  }.to_json
end
