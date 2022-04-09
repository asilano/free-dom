import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    nextIx: Number
  }

  add(event) {
    var input = document.createElement("input");
    input.type = "hidden";
    input.name = "add-fields";
    input.value = 1;
    event.target.form.append(input);
  }

  delete(event) {
    event.preventDefault();

    event.target.closest(".card-select-row").remove();
  }
}
