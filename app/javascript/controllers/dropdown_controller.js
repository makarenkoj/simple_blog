import { Controller } from "@hotwired/stimulus"
import { createPopper } from "@popperjs/core"

export default class extends Controller {
  static targets = ["toggle", "menu"]

  popperInstance = null;

  connect() {
    console.log("Dropdown Stimulus controller connected!");
    this.initializePopper();
  }

  disconnect() {
    if (this.popperInstance) {
      this.popperInstance.destroy();
      this.popperInstance = null;
    }
  }

  initializePopper() {
    if (this.hasToggleTarget && this.hasMenuTarget) {
      this.popperInstance = createPopper(this.toggleTarget, this.menuTarget, {
        modifiers: [
          {
            name: 'offset',
            options: {
              offset: [0, 8],
            },
          },
          {
            name: 'preventOverflow',
            options: {
              padding: 24,
            },
          },
        ],
        placement: 'bottom-end'
      });
      this.menuTarget.classList.add('hidden');
    }
  }

  toggle = (event) => {
    event.preventDefault();
    event.stopPropagation();

    const isShowing = !this.menuTarget.classList.contains('hidden');

    document.querySelectorAll('[data-controller="dropdown"]').forEach(controllerElement => {
      const otherMenu = controllerElement.querySelector('[data-dropdown-target="menu"]');
      if (otherMenu && otherMenu !== this.menuTarget && !otherMenu.classList.contains('hidden')) {
        otherMenu.classList.add('hidden');
        const otherController = this.application.getControllerForElementAndIdentifier(controllerElement, 'dropdown');
        if (otherController && otherController.popperInstance) {
          otherController.popperInstance.setOptions({
            modifiers: [{ name: 'eventListeners', enabled: false }],
          });
        }
      }
    });

    this.menuTarget.classList.toggle('hidden', isShowing);

    if (this.popperInstance) {
      this.popperInstance.setOptions({
        modifiers: [{ name: 'eventListeners', enabled: !this.menuTarget.classList.contains('hidden') }],
      });
      this.popperInstance.update();
    }

    if (!this.menuTarget.classList.contains('hidden')) {
      this.boundHideOnClickOutside = this.hideOnClickOutside.bind(this);
      document.addEventListener('click', this.boundHideOnClickOutside);
    } else {
      document.removeEventListener('click', this.boundHideOnClickOutside);
    }
  }

  hideOnClickOutside = (event) => {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains('hidden')) {
      this.menuTarget.classList.add('hidden');
      if (this.popperInstance) {
        this.popperInstance.setOptions({
          modifiers: [{ name: 'eventListeners', enabled: false }],
        });
      }
      document.removeEventListener('click', this.boundHideOnClickOutside);
    }
  }
}
