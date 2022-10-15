import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"];

  toggle() {
    this.formTarget.classList.toggle("out-of-flow")
  }
}
