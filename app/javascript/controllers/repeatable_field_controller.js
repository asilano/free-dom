import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    nextIx: Number
  }

  add(event) {
    event.preventDefault();

    var url = new URL(this.urlValue);
    url.searchParams.append("ix", this.nextIxValue)

    fetch(url)
      .then((res) => { return res.text() })
      .then((html) => {
        const fragment = document
          .createRange()
          .createContextualFragment(html);

        this.element.appendChild(fragment);
        this.nextIxValue += 1;
      });
  }

  delete(event) {
    event.preventDefault();

    event.target.closest(".card-select-row").remove();
  }
}
