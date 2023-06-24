import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { href: String, frameId: String };

  connect() {
    const link = document.createElement("a");
    link.href = this.hrefValue;
    document.getElementById(this.frameIdValue).appendChild(link);
    link.click();

    this.element.parentElement.removeChild(this.element);
  }
}
