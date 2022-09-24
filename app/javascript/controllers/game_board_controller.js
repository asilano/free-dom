import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { title: String }

  connect() {
    document.title = this.titleValue
  }
}
