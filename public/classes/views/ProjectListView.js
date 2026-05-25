export default class ProjectListView {

  render(projects) {
    const panel = document.querySelector('#main-panel')

    panel.innerHTML = ''

    projects.forEach(project => {
      panel.appendChild(this.buildProjectLine(project))
    })
  }

  buildProjectLine(project) {
    const line = document.createElement('div')

    line.className = 'project-line'
    line.textContent = project.title

    return line
  }

}
