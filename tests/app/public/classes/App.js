import ProjectRepository from './repositories/ProjectRepository.js'
import ProjectListView from './views/ProjectListView.js'

export default class App {

  constructor() {
    this.projectRepository = new ProjectRepository()
    this.projectListView   = new ProjectListView(this.projectRepository)
  }

  async start() {
    const projects = await this.projectRepository.all()
    console.log('[App] projets chargés', projects)
    this.projectListView.render(projects)
  }

}
