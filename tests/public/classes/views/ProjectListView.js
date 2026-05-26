import ListingView from './ListingView.js'

export default class ProjectListView extends ListingView {

  render(projects, options = {}) {
    console.log('[ProjectListView] render', {
      order: projects.map((project, index) => ({
        index,
        id: project.id,
        title: project.title,
        pos: project.pos
      }))
    })

    super.render(
      'projects-listing',
      projects,
      options
    )
  }

  fillItem(line, project) {

    line.classList.add('project-listing__item')

    const title = document.createElement('div')
    title.className = 'project-listing__title'
    title.textContent = project.title

    const id = document.createElement('div')
    id.className = 'project-listing__id'
    id.textContent = project.id

    line.appendChild(title)
    line.appendChild(id)
  }

}
