import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.classList.add("js-active")

    const jsHiddenElems = document.getElementsByClassName("js");
    Array.from(jsHiddenElems).forEach(
      elem => elem.classList.remove("js")
    )

    const jsToHideElems = document.getElementsByClassName("hide-js");
    Array.from(jsToHideElems).forEach(
      elem => elem.classList.replace("hide-js", "out-of-flow")
    )
  }
}
