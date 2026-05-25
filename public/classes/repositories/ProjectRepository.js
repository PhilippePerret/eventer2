export default class ProjectRepository {

  async all() {
    const response = await fetch('/projects')

    if (!response.ok) {
      throw new Error(`Impossible de charger les projets : HTTP ${response.status}`)
    }

    return await response.json()
  }

}
