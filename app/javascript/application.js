// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "trix"
import "@rails/actiontext"

console.log('io QUI outside listener')

document.addEventListener('turbo:load', function() {
  console.log('io QUI turbo:load event fired')

  const toggleButton = document.querySelector('[data-toggle="collapse"]');

  if (toggleButton) {
    const targetSelector = toggleButton.dataset.target;
    if (targetSelector) {
        const targetMenu = document.querySelector(targetSelector);

        if (targetMenu) {
          toggleButton.addEventListener('click', function() {
            const isExpanded = toggleButton.getAttribute('aria-expanded') === 'true';
            toggleButton.setAttribute('aria-expanded', String(!isExpanded));

            if (targetMenu.classList.contains('hidden')) {
              targetMenu.classList.remove('hidden');
              targetMenu.classList.add('flex');
            } else {
              targetMenu.classList.remove('flex');
              targetMenu.classList.add('hidden');
            }
          });
        } else {
          console.error('Target menu element not found for selector:', targetSelector);
        }
    } else {
        console.error('Button has no data-target attribute:', toggleButton);
    }
  } else {
  }
});

console.log('io QUI outside listener end')
