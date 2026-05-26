import ProjectRepository from './repositories/ProjectRepository.js'
import ProjectListView from './views/ProjectListView.js'

export default class App {

  constructor() {
    this.projectRepository = new ProjectRepository()
    this.projectListView   = new ProjectListView()
  }

  async start() {
    const projects = await this.projectRepository.all()

    console.log('[App] start:projects-loaded', {
      order: projects.map(project => ({ id: project.id, title: project.title }))
    })

    this.projectListView.render(
      projects,
      {
        onReorder: reorderedProjects => {
          console.log('[App] projects:reorder', {
            order: reorderedProjects.map(project => project.id)
          })
          this.projectRepository.reorder(reorderedProjects)
        }
      }
    )
  }

}
