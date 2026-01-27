import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Додати класи анімації при завантаженні
    this.element.classList.add('animate-slideUp')
  }
}
