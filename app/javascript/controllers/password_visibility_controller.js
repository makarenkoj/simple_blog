import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "eye", "eyeSlash" ]

  toggle(event) {
    event.preventDefault()

    if (this.inputTarget.type === "password") {
      this.inputTarget.type = "text"
      this.eyeTarget.classList.add("hidden")
      this.eyeSlashTarget.classList.remove("hidden")
    } else {
      this.inputTarget.type = "password"
      this.eyeTarget.classList.remove("hidden")
      this.eyeSlashTarget.classList.add("hidden")
    }
  }
}
