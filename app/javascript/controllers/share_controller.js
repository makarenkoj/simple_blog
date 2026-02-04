import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "copyIcon", "checkIcon", "copyText"]
  static values = {
    url: String,
    title: String
  }

  connect() {
    this.clickOutsideHandler = this.clickOutside.bind(this)
    document.addEventListener("click", this.clickOutsideHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutsideHandler)
  }

  toggle(event) {
    if (navigator.share && this.isMobile()) {
      navigator.share({
        title: this.titleValue,
        url: this.urlValue
      }).catch(console.error)
    } else {
      this.menuTarget.classList.toggle("hidden")
    }
  }

  async copy(event) {
    event.preventDefault()
    try {
      await navigator.clipboard.writeText(this.urlValue)
      this.showCopiedState()
    } catch (err) {
      console.error('Failed to copy!', err)
    }
  }

  showCopiedState() {
    this.copyIconTarget.classList.add("hidden")
    this.checkIconTarget.classList.remove("hidden")
    const originalText = this.copyTextTarget.innerText
    this.copyTextTarget.innerText = "Скопійовано!"

    setTimeout(() => {
      this.copyIconTarget.classList.remove("hidden")
      this.checkIconTarget.classList.add("hidden")
      this.copyTextTarget.innerText = originalText
    }, 2000)
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  isMobile() {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
  }
}
