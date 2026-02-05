import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner"]

  connect() {
    if (!localStorage.getItem("cookie_consent")) {
      this.show()
    }
  }

  accept() {
    localStorage.setItem("cookie_consent", "true")
    this.hide()
  }

  show() {
    this.bannerTarget.classList.remove("hidden")
    setTimeout(() => {
        this.bannerTarget.classList.remove("translate-y-full")
    }, 100)
  }

  hide() {
    this.bannerTarget.classList.add("translate-y-full")
    setTimeout(() => {
        this.bannerTarget.classList.add("hidden")
    }, 300)
  }
}
