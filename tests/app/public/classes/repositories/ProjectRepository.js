export default class ProjectRepository {

  async all() {
    const response = await fetch('/projects')

    if (!response.ok) {
      throw new Error(`Impossible de charger les projets : HTTP ${response.status}`)
    }

    return await response.json()
  }

  async reorder(order) {
    const response = await fetch('/projects/reorder', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ order })
    })

    if (!response.ok) {
      throw new Error(`Impossible d'enregistrer l'ordre des projets : HTTP ${response.status}`)
    }

    return await response.json()
  }

}
