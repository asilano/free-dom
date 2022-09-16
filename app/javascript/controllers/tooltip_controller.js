import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }

  connect() {
    this.tooltip_elem = document.createElement("div");
    this.tooltip_elem.innerHTML = this.textValue;
    this.tooltip_elem.className = "tooltip top align-center transparent";
    this.element.append(this.tooltip_elem);
    this.tooltip_elem.style.fontWeight = "normal";
    this.tooltip_elem.style.width = "15rem";

    // Prevent tooltip triggering itself when invisible
    this.tooltip_elem.style.pointerEvents = "none";
  }

  show(event) {
    if (event.target != this.element)
      return;

    this.tooltip_elem.className = "tooltip top align-center transparent";

    // Allow tooltip to remain when self-hovered
    this.tooltip_elem.style.pointerEvents = "auto";

    this.tooltip_elem.style.left = "calc((" + this.element.clientWidth + "px - 15rem) / 2)";
    this.tooltip_elem.style.top = "calc(0px - " + this.tooltip_elem.clientHeight + "px - 0.75rem)";
    var bounds = this.tooltip_elem.getBoundingClientRect()

    if (bounds.left < 5) {
      var rightShift = 5 - bounds.left;
      this.tooltip_elem.style.left = "calc((" + this.element.clientWidth + "px - 15rem) / 2 + " + rightShift + "px)";
      this.tooltip_elem.classList.remove("align-center");
      this.tooltip_elem.classList.add("align-left");
    }

    if (bounds.right > window.innerWidth - 5) {
      var leftShift = bounds.right - window.innerWidth + 5;
      this.tooltip_elem.style.left = "calc((" + this.element.clientWidth + "px - 15rem) / 2 - " + leftShift + "px)";
      this.tooltip_elem.classList.remove("align-center");
      this.tooltip_elem.classList.add("align-right");
    }

    if (bounds.top < 5) {
      this.tooltip_elem.style.top = "calc(" + this.element.clientHeight +"px + 0.75rem)";
      this.tooltip_elem.classList.remove("top");
      this.tooltip_elem.classList.add("bottom");
    }

    this.tooltip_elem.style.transition = "opacity 0.25s"
    this.tooltip_elem.classList.remove("transparent")
  }

  hide() {
    this.tooltip_elem.classList.add("transparent")

    // Prevent tooltip triggering itself when invisible
    this.tooltip_elem.style.pointerEvents = "none";
  }

  convertRemToPx(rem) {
    return rem * parseFloat(getComputedStyle(document.documentElement).fontSize);
  }
}
