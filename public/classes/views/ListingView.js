export default class ListingView {

  constructor() {
    this.currentIndex = 0
    this.items = []
  }

  render(panelClass, items) {

    this.panelClass = panelClass
    this.items      = items

    const panel = document.querySelector('#main-panel')

    panel.className = panelClass
    panel.innerHTML = ''

    const listing = document.createElement('div')
    listing.className = 'listing'

    items.forEach((item, index) => {
      listing.appendChild(
        this.buildItemWrapper(item, index)
      )
    })

    panel.appendChild(listing)

    this.bindKeyboardNavigation()
  }

  buildItemWrapper(item, index) {
    const line = document.createElement('div')

    line.className = this.itemClass(index)

    this.fillItem(line, item, index)

    return line
  }

  itemClass(index) {
    const classes = ['event']

    if (this.currentIndex === index) {
      classes.push('selected')
    }

    return classes.join(' ')
  }


  bindKeyboardNavigation() {

    document.onkeydown = (event) => {

      switch(event.key) {

      case 'ArrowDown':
        this.selectNextItem()
        break

      case 'ArrowUp':
        this.selectPreviousItem()
        break
      }
    }
  }

  selectNextItem() {

    if (this.currentIndex >= this.items.length - 1) return

    this.currentIndex += 1

    this.refreshSelection()
  }

  selectPreviousItem() {

    if (this.currentIndex <= 0) return

    this.currentIndex -= 1

    this.refreshSelection()
  }

  refreshSelection() {

    const items = document.querySelectorAll('.event')

    items.forEach((item, index) => {

      if (index === this.currentIndex) {
        item.classList.add('selected')
      } else {
        item.classList.remove('selected')
      }
    })
  }


  fillItem(_line, _item, _index) {
    throw new Error('fillItem must be implemented')
  }

}
