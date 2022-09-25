import Sortable from 'stimulus-sortable'

export default class extends Sortable {
  connect() {
    super.connect()

    this.reorder_controls = Array.from(this.element.getElementsByClassName("reorder-no-js"))
    this.reorder_controls.forEach(el => {
      const sel = el.getElementsByTagName("select")[0]
      const positionSpan = document.createElement("span");
      positionSpan.classList = "reorder-position"
      positionSpan.textContent = sel.options[sel.selectedIndex].text
      sel.parentNode.append(positionSpan)
      sel.style.display = "none";
    });
  }

  get options () {
    return {
      ...super.options,
      filter: ".unsortable",
      preventOnFilter: true,
      onStart: this.start,
      onMove: this.move,
      onEnd: this.end
    }
  }

  start({item}) {
    // Suppress the card's tooltip while dragging.
    item.querySelector("[data-controller~='tooltip']").dispatchEvent(new Event("dragged"))
  }

  async end ({ item, oldIndex, newIndex }) {
    await super.end({ item, newIndex })
    this.reorder_controls.forEach((el, ix) => {
      const sel = el.getElementsByTagName("select")[0]
      const positionSpan = sel.parentNode.getElementsByClassName("reorder-position")[0]

      const elsOldIndex = sel.value - 1
      if (oldIndex < newIndex && (elsOldIndex > oldIndex && elsOldIndex <= newIndex)) {
        sel.value = +sel.value - 1
      }
      if (oldIndex > newIndex && (elsOldIndex < oldIndex && elsOldIndex >= newIndex)) {
        sel.value = +sel.value + 1
      }
      if (elsOldIndex == oldIndex) {
        sel.value = newIndex + 1
      }
      positionSpan.textContent = sel.options[sel.selectedIndex].text
    })

    this.tooltip = item.getElementsByClassName("tooltip")[0]
    this.tooltip_visible = !this.tooltip.classList.contains("transparent")
    if (this.tooltip_visible) {
      this.tooltip.classList.add("transparent")
      this.tooltip.style.pointerEvents = "none";
    }
  }

  move({ related }) {
    return !related.classList.contains("unsortable")
  }
}
