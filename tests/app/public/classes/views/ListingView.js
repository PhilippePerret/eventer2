export default class ListingView {

  constructor() {
    this.currentIndex = 0
    this.items = []
    this.panelClass = null
  }

  render(panelClass, items) {

    this.panelClass = panelClass
    this.items      = items

    if (this.currentIndex > this.items.length - 1) {
      this.currentIndex = Math.max(0, this.items.length - 1)
    }

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

      if ((event.metaKey || event.ctrlKey) && event.key === 'ArrowDown') {
        event.preventDefault()
        this.moveCurrentItem(1)
        return
      }

      if ((event.metaKey || event.ctrlKey) && event.key === 'ArrowUp') {
        event.preventDefault()
        this.moveCurrentItem(-1)
        return
      }

      switch(event.key) {

      case 'ArrowDown':
        event.preventDefault()
        this.selectNextItem()
        break

      case 'ArrowUp':
        event.preventDefault()
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

  moveCurrentItem(offset) {

    if (!this.items.length) return

    const sourceIndex = this.currentIndex
    const targetIndex = sourceIndex + offset

    if (targetIndex < 0) return
    if (targetIndex >= this.items.length) return

    console.log('[ListingView] move item', { sourceIndex, targetIndex })

    const movedItem = this.items[sourceIndex]

    this.items.splice(sourceIndex, 1)
    this.items.splice(targetIndex, 0, movedItem)

    this.currentIndex = targetIndex

    this.render(this.panelClass, this.items)
    this.afterItemsReordered(this.items)
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

  afterItemsReordered(_items) {
  }

  fillItem(_line, _item, _index) {
    throw new Error('fillItem must be implemented')
  }

}
