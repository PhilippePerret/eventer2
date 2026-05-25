export default class App {

  async start() {
    const projects = await this.loadProjects()
    this.renderProjects(projects)
  }

  async loadProjects() {
    return [
      { id: '__e2e__', title: '__e2e__' }
    ]
  }

  renderProjects(projects) {
    const panel = document.querySelector('#main-panel')

    panel.innerHTML = ''

    projects.forEach(project => {
      const div = document.createElement('div')
      div.className = 'project-line'
      div.textContent = project.title
      panel.appendChild(div)
    })
  }

}
