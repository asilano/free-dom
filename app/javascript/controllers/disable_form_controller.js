import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["disablingElement"];

  disableElements(e) {
    this.disablingElementTargets.forEach(e => e.disabled = true);
  }
}
