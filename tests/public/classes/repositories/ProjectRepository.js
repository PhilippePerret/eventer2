export default class ProjectRepository {

  async all() {
    console.log('[ProjectRepository] all:start')

    const response = await fetch('/projects')

    console.log('[ProjectRepository] all:response', {
      ok: response.ok,
      status: response.status
    })

    if (!response.ok) {
      throw new Error(`Impossible de charger les projets : HTTP ${response.status}`)
    }

    const projects = await response.json()

    console.log('[ProjectRepository] all:projects', {
      order: projects.map((project, index) => ({
        index,
        id: project.id,
        title: project.title,
        pos: project.pos
      }))
    })

    return projects
  }

  async reorder(projects) {
    const order = projects.map(project => project.id)

    console.log('[ProjectRepository] reorder:start', { order })

    const response = await fetch('/projects/order', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ order })
    })

    console.log('[ProjectRepository] reorder:response', {
      ok: response.ok,
      status: response.status,
      order
    })

    if (!response.ok) {
      throw new Error(`Impossible de réordonner les projets : HTTP ${response.status}`)
    }

    const payload = await response.json()

    console.log('[ProjectRepository] reorder:payload', payload)

    return payload
  }

}
