import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  navigate(event) {
    const isInteractive = event.target.closest('button, a, form, input, [data-action*="stopPropagation"]')

    if (isInteractive) {
      return
    }

    if (this.urlValue) {
      if (window.Turbo) {
        window.Turbo.visit(this.urlValue)
      } else {
        window.location.href = this.urlValue
      }
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
