export default class ItemCollection {

  constructor(items = []) {
    this.items = items
  }

  get orderedItems() {
    return [...this.items].sort((a, b) => a.pos - b.pos)
  }

  move(item, targetIndex) {

    const ordered = this.orderedItems.filter(i => i !== item)

    const before = ordered[targetIndex - 1] || null
    const after  = ordered[targetIndex] || null

    if (!this.canInsertBetween(before, after)) {
      return {
        success: false,
        reason: 'REINDEX_REQUIRED'
      }
    }

    item.pos = this.computeIntermediatePosition(before, after)

    return {
      success: true,
      pos: item.pos
    }
  }

  canInsertBetween(before, after) {

    if (!before || !after) {
      return true
    }

    return Math.abs(after.pos - before.pos) >= 2
  }

  computeIntermediatePosition(before, after) {

    if (!before && !after) {
      return 1000
    }

    if (!before) {
      return after.pos - 1000
    }

    if (!after) {
      return before.pos + 1000
    }

    return Math.floor((before.pos + after.pos) / 2)
  }

  recalculatePositions(step = 1000) {

    this.orderedItems.forEach((item, index) => {
      item.pos = (index + 1) * step
    })
  }
}
