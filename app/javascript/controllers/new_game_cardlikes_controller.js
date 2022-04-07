import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="new-game-cardlikes"
export default class extends Controller {
  connect() {
  }

  add(event) {
    console.log("Clicked")
    event.preventDefault();
    event.target.firstChild.data = "Clicked";
  }
}
