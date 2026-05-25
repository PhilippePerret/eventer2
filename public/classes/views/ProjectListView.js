export default class ProjectListView {

  render(projects) {
    const panel = document.querySelector('#main-panel')

    panel.className = 'projects-listing'
    panel.innerHTML = ''

    const list = document.createElement('div')
    list.className = 'project-listing'

    projects.forEach(project => {
      list.appendChild(this.buildProjectLine(project))
    })

    panel.appendChild(list)
  }

  buildProjectLine(project) {
    const line = document.createElement('div')
    line.className = 'project-listing__item'

    const title = document.createElement('div')
    title.className = 'project-listing__title'
    title.textContent = project.title

    const id = document.createElement('div')
    id.className = 'project-listing__id'
    id.textContent = project.id

    line.appendChild(title)
    line.appendChild(id)

    return line
  }

}
