export default class ListingView {

  constructor() {
    this.currentIndex = 0
    this.items = []
    this.panelClass = null
    this.onReorder = null
  }

  render(panelClass, items, options = {}) {

    this.panelClass = panelClass
    this.items      = items
    this.onReorder  = options.onReorder || this.onReorder

    if (this.currentIndex >= this.items.length) {
      this.currentIndex = Math.max(0, this.items.length - 1)
    }

    console.log('[ListingView] render', {
      panelClass: this.panelClass,
      currentIndex: this.currentIndex,
      order: this.loggableOrder()
    })

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

      console.log('[ListingView] keydown', {
        key: event.key,
        metaKey: event.metaKey,
        ctrlKey: event.ctrlKey,
        currentIndex: this.currentIndex,
        selected: this.loggableItem(this.items[this.currentIndex])
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

    console.log('[ListingView] selectNextItem', {
      currentIndex: this.currentIndex,
      selected: this.loggableItem(this.items[this.currentIndex])
    })

    this.refreshSelection()
  }

  selectPreviousItem() {

    if (this.currentIndex <= 0) return

    this.currentIndex -= 1

    console.log('[ListingView] selectPreviousItem', {
      currentIndex: this.currentIndex,
      selected: this.loggableItem(this.items[this.currentIndex])
    })

    this.refreshSelection()
  }

  moveSelectedItem(direction) {
    const sourceIndex = this.currentIndex
    const targetIndex = sourceIndex + direction

    console.log('[ListingView] moveSelectedItem:start', {
      direction,
      sourceIndex,
      targetIndex,
      selected: this.loggableItem(this.items[sourceIndex]),
      orderBefore: this.loggableOrder()
    })

    if (targetIndex < 0 || targetIndex >= this.items.length) {
      console.log('[ListingView] moveSelectedItem:blocked', {
        reason: 'OUT_OF_RANGE',
        sourceIndex,
        targetIndex,
        order: this.loggableOrder()
      })
      return
    }

    const reorderedItems = [...this.items]
    const movedItems = reorderedItems.splice(sourceIndex, 1)
    const movedItem = movedItems[0]

    reorderedItems.splice(targetIndex, 0, movedItem)

    this.items = reorderedItems
    this.currentIndex = targetIndex

    console.log('[ListingView] moveSelectedItem:after-mutation', {
      moved: this.loggableItem(movedItem),
      sourceIndex,
      targetIndex,
      orderAfter: this.loggableOrder()
    })

    this.render(this.panelClass, this.items, { onReorder: this.onReorder })

    if (this.onReorder) {
      console.log('[ListingView] moveSelectedItem:onReorder', {
        order: this.items.map(item => item.id)
      })
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
  }

  loggableOrder() {
    return this.items.map((item, index) => ({
      index,
      id: item.id,
      title: item.title,
      pos: item.pos
    }))
  }

  loggableItem(item) {
    if (!item) return null

    return {
      id: item.id,
      title: item.title,
      pos: item.pos
    }
  }

  fillItem(_line, _item, _index) {
    throw new Error('fillItem must be implemented')
  }

}
