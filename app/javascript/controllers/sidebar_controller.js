import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebarMenu", "sidebarOverlay", "mainContent", "dropdownToggle"]

  connect() {
    this.sidebarMenuTarget.classList.add("-translate-x-full");
    this.sidebarOverlayTarget.classList.add("hidden");
    this.mainContentTarget.classList.remove("md:ml-64");
    this.mainContentTarget.classList.remove("active");

    this.clickOutsideHandler = this.clickOutside.bind(this)
    document.addEventListener("click", this.clickOutsideHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutsideHandler)
  }

  clickOutside(event) {
    if (this.sidebarMenuTarget.classList.contains("-translate-x-full")) return;

    if (this.sidebarMenuTarget.contains(event.target)) return;

    if (event.target.closest('[data-action*="sidebar#toggleSidebar"]')) return;

    this.closeSidebar()
  }

  toggleSidebar = (event) => {
    event.preventDefault();
    event.stopPropagation();

    const isSidebarHidden = this.sidebarMenuTarget.classList.contains("-translate-x-full");

    if (isSidebarHidden) {
      this.openSidebar();
    } else {
      this.closeSidebar();
    }
  }

  openSidebar() {
    this.sidebarMenuTarget.classList.remove("-translate-x-full");
    this.sidebarOverlayTarget.classList.remove("hidden");
    this.mainContentTarget.classList.remove("active");
    this.mainContentTarget.classList.add("md:ml-64");
  }

  closeSidebar() {
    this.sidebarMenuTarget.classList.add("-translate-x-full");
    this.sidebarOverlayTarget.classList.add("hidden");
    this.mainContentTarget.classList.add("active");
    this.mainContentTarget.classList.remove("md:ml-64");
  }

  hideSidebar = (event) => {
    event.preventDefault();
    this.closeSidebar();
  }

  toggleDropdown = (event) => {
    const parent = event.currentTarget.closest('.group');

    if (parent.classList.contains('selected')) {
      parent.classList.remove('selected');
    } else {
      this.dropdownToggleTargets.forEach(item => {
        item.closest('.group').classList.remove('selected');
      });
      parent.classList.add('selected');
    }
  }
}
