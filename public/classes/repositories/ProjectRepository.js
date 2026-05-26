export default class ProjectRepository {

  async all() {
    const response = await fetch('/projects')

    if (!response.ok) {
      throw new Error(`Impossible de charger les projets : HTTP ${response.status}`)
    }

    return await response.json()
  }

  reorder(projects) {
    const order = projects.map(project => project.id)

    console.log('[ProjectRepository] reorder:start', { order })

    const request = new XMLHttpRequest()
    request.open('POST', '/projects/reorder', false)
    request.setRequestHeader('Content-Type', 'application/json')
    request.send(JSON.stringify({ order }))

    if (request.status < 200 || request.status >= 300) {
      console.error('[ProjectRepository] reorder:failed', {
        status: request.status,
        response: request.responseText
      })
      throw new Error(`Impossible de réordonner les projets : HTTP ${request.status}`)
    }

    console.log('[ProjectRepository] reorder:success', { order })
  }

}
