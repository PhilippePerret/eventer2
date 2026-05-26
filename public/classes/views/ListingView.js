export default class ListingView {

  constructor() {
    this.currentIndex = 0
    this.items = []
    this.onReorder = null
  }

  render(panelClass, items, options = {}) {

    this.panelClass = panelClass
    this.items      = items
    this.onReorder  = options.onReorder || null

    if (this.currentIndex >= this.items.length) {
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

    console.log('[ListingView] render', {
      panelClass: this.panelClass,
      selectedIndex: this.currentIndex,
      order: this.items.map(item => item.id || item.title || item)
    })

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

      console.log('[ListingView] keydown', {
        key: event.key,
        metaKey: event.metaKey,
        ctrlKey: event.ctrlKey,
        currentIndex: this.currentIndex
      })

      if (event.metaKey || event.ctrlKey) {
        switch(event.key) {

        case 'ArrowDown':
          event.preventDefault()
          this.moveSelectedItem(1)
          return

        case 'ArrowUp':
          event.preventDefault()
          this.moveSelectedItem(-1)
          return
        }
      }

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

    console.log('[ListingView] selectNextItem', { currentIndex: this.currentIndex })

    this.refreshSelection()
  }

  selectPreviousItem() {

    if (this.currentIndex <= 0) return

    this.currentIndex -= 1

    console.log('[ListingView] selectPreviousItem', { currentIndex: this.currentIndex })

    this.refreshSelection()
  }

  moveSelectedItem(direction) {

    const sourceIndex = this.currentIndex
    const targetIndex = sourceIndex + direction

    console.log('[ListingView] moveSelectedItem:start', {
      direction,
      sourceIndex,
      targetIndex,
      orderBefore: this.items.map(item => item.id || item.title || item)
    })

    if (targetIndex < 0 || targetIndex >= this.items.length) {
      console.log('[ListingView] moveSelectedItem:blocked', { sourceIndex, targetIndex })
      return
    }

    const listing = document.querySelector('.listing')
    const nodes = listing.querySelectorAll('.event')

    const sourceNode = nodes[sourceIndex]
    const targetNode = nodes[targetIndex]

    const movedItem = this.items[sourceIndex]

    this.items.splice(sourceIndex, 1)
    this.items.splice(targetIndex, 0, movedItem)

    if (direction < 0) {
      listing.insertBefore(sourceNode, targetNode)
    } else {
      listing.insertBefore(targetNode, sourceNode)
    }

    this.currentIndex = targetIndex

    this.refreshSelection()

    console.log('[ListingView] moveSelectedItem:dom-updated', {
      currentIndex: this.currentIndex,
      orderAfter: this.items.map(item => item.id || item.title || item)
    })

    if (this.onReorder) {
      this.onReorder(this.items)
    }
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

    console.log('[ListingView] refreshSelection', { currentIndex: this.currentIndex })
  }


  fillItem(_line, _item, _index) {
    throw new Error('fillItem must be implemented')
  }

}
