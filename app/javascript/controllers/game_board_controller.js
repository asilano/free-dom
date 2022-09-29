import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { title: String }
  static targets = ["journals"]

  connect() {
    document.title = this.titleValue
    this.journalsTarget.scrollTop = this.journalsTarget.scrollHeight
  }
}
