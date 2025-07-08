import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    console.log("Hello from TailwindTest Stimulus controller!");
    this.messageTarget.textContent = "Stimulus контролер успішно завантажений та активний!";
    this.messageTarget.classList.add("font-semibold", "text-green-700");
  }
}
