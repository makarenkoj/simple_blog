import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebarMenu", "sidebarOverlay", "mainContent", "dropdownToggle"]

  connect() {
    console.log("Sidebar Stimulus controller connected!");

    this.sidebarMenuTarget.classList.add("-translate-x-full");
    this.sidebarOverlayTarget.classList.add("hidden");
    this.mainContentTarget.classList.remove("md:ml-64");
    this.mainContentTarget.classList.remove("active");
}

  toggleSidebar = (event) => {
    event.preventDefault();

    const isSidebarHidden = this.sidebarMenuTarget.classList.contains("-translate-x-full");

    if (isSidebarHidden) {
      this.sidebarMenuTarget.classList.remove("-translate-x-full");
      this.sidebarOverlayTarget.classList.remove("hidden");
      this.mainContentTarget.classList.remove("active");
      this.mainContentTarget.classList.add("md:ml-64");
    } else {
      this.sidebarMenuTarget.classList.add("-translate-x-full");
      this.sidebarOverlayTarget.classList.add("hidden");
      this.mainContentTarget.classList.add("active");
      this.mainContentTarget.classList.remove("md:ml-64");
    }
  }

  hideSidebar = (event) => {
    event.preventDefault();
    this.sidebarMenuTarget.classList.add("-translate-x-full");
    this.sidebarOverlayTarget.classList.add("hidden");
    this.mainContentTarget.classList.add("active");
    this.mainContentTarget.classList.remove("md:ml-64");
  }

  toggleDropdown = (event) => {
    event.preventDefault();
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
