require 'sinatra'
require 'json'
require_relative './lib/eventer/bootstrap'
require_relative './lib/eventer/data_paths'
require_relative './lib/eventer/http_helpers'
require_relative './lib/eventer/project_repository'
require_relative './lib/eventer/eventer_repository'

set :public_folder, 'public'

DATA_DIR = File.expand_path('data', __dir__)

paths = Eventer::DataPaths.new(DATA_DIR)

configure do
  set :eventer_paths, paths
  set :project_repository, Eventer::ProjectRepository.new(paths)
  set :eventer_repository, Eventer::EventerRepository.new(paths)
end

Eventer::Bootstrap.new(paths).ensure_initial_data!

helpers Eventer::HttpHelpers

before do
  content_type :json if request.path_info.start_with?('/projects', '/events', '/child')
end

get '/' do
  content_type :html
  send_file File.join(settings.public_folder, 'index.html')
end

get '/projects' do
  settings.project_repository.all.to_json
end

post '/projects' do
  payload = request_payload
  project = settings.project_repository.create(payload['name'].to_s)
  { status: 'ok', project: project, filename: "#{project[:id]}.json" }.to_json
end

patch '/projects/:project' do
  project = settings.project_repository.update(params[:project], request_payload)
  { status: 'ok', project: project }.to_json
end

delete '/projects/:project' do
  project = settings.project_repository.deactivate(params[:project])
  { status: 'ok', project: project[:id], active: false }.to_json
end

post '/projects/reorder' do
  settings.project_repository.reorder(request_payload['order'] || [])
  { status: 'ok' }.to_json
end

post '/projects/order' do
  settings.project_repository.reorder(request_payload['order'] || [])
  { status: 'ok' }.to_json
end

get '/events' do
  project_id = params[:project] || Eventer::Bootstrap::DEMO_PROJECT_ID
  child_path = params[:path] || ''
  settings.eventer_repository.load(project_id, child_path).to_json
end

post '/events' do
  project_id = params[:project] || Eventer::Bootstrap::DEMO_PROJECT_ID
  child_path = params[:path] || ''
  settings.eventer_repository.save(project_id, child_path, request_payload)
  { status: 'ok', project: project_id, path: child_path }.to_json
end

post '/child' do
  project_id = params[:project] || Eventer::Bootstrap::DEMO_PROJECT_ID
  child_path = settings.eventer_repository.ensure_child(
    project_id,
    params[:path] || '',
    request_payload
  )
  { status: 'ok', project: project_id, path: child_path }.to_json
end
