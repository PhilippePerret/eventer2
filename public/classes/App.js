import ProjectRepository from './repositories/ProjectRepository.js'
import ProjectListView from './views/ProjectListView.js'

export default class App {

  constructor() {
    this.projectRepository = new ProjectRepository()
    this.projectListView   = new ProjectListView()
  }

  async start() {
    const projects = await this.projectRepository.all()
    console.log("Je vais afficher les projets : ", projects)
    this.projectListView.render(projects)
  }

}
