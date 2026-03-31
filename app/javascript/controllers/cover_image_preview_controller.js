import { Controller } from "@hotwired/stimulus"

const ALLOWED_TYPES = ["image/png", "image/jpeg", "image/gif", "image/webp"]

export default class extends Controller {
  static targets = ["input", "error", "size", "previewWrapper", "previewImage"]
  static values = {
    maxSize: Number,
    invalidTypeMessage: String,
    invalidSizeMessage: String
  }

  selectFile() {
    const file = this.inputTarget.files[0]

    this.resetUi()
    if (!file) return

    if (!ALLOWED_TYPES.includes(file.type)) {
      this.showError(this.invalidTypeMessageValue)
      this.inputTarget.value = ""
      return
    }

    if (file.size > this.maxSizeValue) {
      this.showError(this.invalidSizeMessageValue)
      this.inputTarget.value = ""
      return
    }

    this.showSize(file.size)
    this.showPreview(file)
  }

  resetUi() {
    this.errorTarget.textContent = ""
    this.errorTarget.classList.add("hidden")
    this.sizeTarget.textContent = ""
    this.sizeTarget.classList.add("hidden")
    this.previewImageTarget.removeAttribute("src")
    this.previewWrapperTarget.classList.add("hidden")
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
  }

  showSize(bytes) {
    this.sizeTarget.textContent = `Розмір файлу: ${this.humanSize(bytes)}`
    this.sizeTarget.classList.remove("hidden")
  }

  showPreview(file) {
    const reader = new FileReader()
    reader.onload = (event) => {
      this.previewImageTarget.src = event.target.result
      this.previewWrapperTarget.classList.remove("hidden")
    }
    reader.readAsDataURL(file)
  }

  humanSize(bytes) {
    if (bytes < 1024) return `${bytes} B`
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
  }
}
