import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 4000 }
  }

  connect() {
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, this.delayValue)
  }

  dismiss() {
    this.element.classList.add("transition-opacity", "duration-1000", "ease-out", "opacity-0")

    setTimeout(() => {
      this.element.remove()
    }, 1000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
