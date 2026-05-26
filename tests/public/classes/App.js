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
      order: projects.map((project, index) => ({
        index,
        id: project.id,
        title: project.title,
        pos: project.pos
      }))
    })

    this.projectListView.render(projects, {
      onReorder: async reorderedProjects => {
        console.log('[App] projects:onReorder', {
          order: reorderedProjects.map((project, index) => ({
            index,
            id: project.id,
            title: project.title,
            pos: project.pos
          }))
        })

        await this.projectRepository.reorder(reorderedProjects)
      }
    })
  }

}
