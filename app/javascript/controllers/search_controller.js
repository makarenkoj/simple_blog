import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  static values = {
    minLength: { type: Number, default: 2 },
    debounceDelay: { type: Number, default: 300 }
  }

  connect() {
    this.clickOutsideHandler = this.clickOutside.bind(this)
    document.addEventListener("click", this.clickOutsideHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutsideHandler)
  }

  query() {
    clearTimeout(this.timeout)
    const query = this.inputTarget.value.trim()

    if (query.length < this.minLengthValue) {
      this.hideResults()
      return
    }

    this.timeout = setTimeout(() => {
      this.performSearch()
    }, this.debounceDelayValue)
  }

  performSearch() {
    this.element.requestSubmit()
    this.showResults()
  }

  submitFullPage(event) {
    this.element.removeAttribute("data-turbo-frame")
    setTimeout(() => {
      this.element.setAttribute("data-turbo-frame", "search_results")
    }, 200)
  }

  showResults() {
    if (this.hasResultsTarget) {
      this.resultsTarget.classList.remove("hidden")
    }
  }

  hideResults() {
    if (this.hasResultsTarget) {
      this.resultsTarget.classList.add("hidden")
    }
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }

  handleKeydown(event) {
    switch(event.key) {
      case "Escape":
        this.hideResults()
        this.inputTarget.blur()
        break
      case "Enter":
        this.submitFullPage(event)
        break
    }
  }

  handleFocus() {
    const query = this.inputTarget.value.trim()
    if (query.length >= this.minLengthValue) {
      this.showResults()
    }
  }
}
