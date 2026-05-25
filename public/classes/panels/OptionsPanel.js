class OptionsPanel {

  constructor(db) {
    this.db = db
    this.overlay = document.querySelector('#panel-overlay')
    this.container = document.querySelector('#panel')
    this.previousPanel = null
  }

  open() {
    this.previousPanel = UI.panel || null
    UI.panel = this

    if (this.overlay) this.overlay.classList.remove('hidden')
    this.render()
  }

  close() {
    UI.panel = this.previousPanel || null

    if (this.previousPanel) {
      this.previousPanel.render()
      return
    }

    if (this.overlay) this.overlay.classList.add('hidden')
  }

  render() {
    if (!this.container) return

    this.container.innerHTML = ''

    const header = document.createElement('div')
    header.className = 'panel-header'

    const title = document.createElement('div')
    title.className = 'panel-title'
    title.textContent = 'Options'

    const close = document.createElement('button')
    close.type = 'button'
    close.className = 'panel-close'
    close.textContent = 'Fermer · Cmd+Enter'
    close.addEventListener('click', () => this.close())

    header.append(title, close)

    const row = document.createElement('label')
    row.className = 'option-row selected'

    const check = document.createElement('input')
    check.type = 'checkbox'
    check.checked = !!this.db.options.colorizeEventsWithFirstBrin

    const text = document.createElement('span')
    text.textContent = 'Coloriser les events avec couleur premier brin'

    check.addEventListener('change', () => {
      this.db.options.colorizeEventsWithFirstBrin = check.checked
      eventsPanel.render()
      scheduleSave()
    })

    row.append(check, text)
    this.container.append(header, row)
  }

  handleKeydown(e) {
    if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') {
      e.preventDefault()
      this.close()
      return true
    }

    if (e.key === 'Escape') {
      e.preventDefault()
      this.close()
      return true
    }

    if (e.key === ' ' || e.key === 'Enter') {
      e.preventDefault()
      this.db.options.colorizeEventsWithFirstBrin = !this.db.options.colorizeEventsWithFirstBrin
      eventsPanel.render()
      this.render()
      scheduleSave()
      return true
    }

    return false
  }

}
