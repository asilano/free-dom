import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nameEntry", "randomName"]

  useName() {
    this.nameEntryTarget.value = this.randomNameTarget.innerText
  }

  updateRandomName(event) {
    this.randomNameTarget.innerText = event.detail[0]
  }
}