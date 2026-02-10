import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tabButton", "tabContent"]

  connect() {
    console.log("Tabs Stimulus controller connected!");
    const defaultTabButton = this.tabButtonTargets.find(btn => btn.dataset.tabPage === "notifications");
    if (defaultTabButton) {
      this.selectTab({ currentTarget: defaultTabButton, preventDefault: () => {} });
    }
  }

  selectTab = (event) => {
    if (typeof event.preventDefault === 'function') {
      event.preventDefault();
    }

    const selectedButton = event.currentTarget;
    const pageName = selectedButton.dataset.tabPage;
    const tabGroup = selectedButton.dataset.tab;

    this.tabButtonTargets.forEach(button => {
      if (button.dataset.tab === tabGroup) {
        button.classList.remove('active', 'border-b-[#f84525]', 'text-gray-900');
        button.classList.add('border-b-transparent', 'text-gray-400');
      }
    });

    selectedButton.classList.add('active', 'border-b-[#f84525]', 'text-gray-900');
    selectedButton.classList.remove('border-b-transparent', 'text-gray-400');

    this.tabContentTargets.forEach(page => {
      if (page.dataset.tabFor === tabGroup) {
        page.classList.add('hidden');
      }
    });

    const targetPage = this.tabContentTargets.find(page =>
      page.dataset.tabFor === tabGroup && page.dataset.page === pageName
    );
    if (targetPage) {
      targetPage.classList.remove('hidden');
    }
  }
}
