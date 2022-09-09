import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.querySelectorAll("[data-tooltip]").forEach(
      x => new Foundation.Tooltip($(x))
    );
  }
}
