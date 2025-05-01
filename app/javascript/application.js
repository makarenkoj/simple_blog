// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"

console.log('io QUI')

document.addEventListener('turbolinks:load', function() {
  console.log('io QUI')

  const toggleButton = document.querySelector('[data-toggle="collapse"]');
  const targetMenu = document.querySelector('#' + toggleButton.dataset.target.substring(1)); // Отримуємо ID без #
  if (toggleButton && targetMenu) {
    toggleButton.addEventListener('click', function() {
      const isExpanded = toggleButton.getAttribute('aria-expanded') === 'true';
      toggleButton.setAttribute('aria-expanded', !isExpanded);

      if (targetMenu.classList.contains('hidden')) {
        targetMenu.classList.remove('hidden');
        targetMenu.classList.add('flex'); // Або block, залежно від того, як ви його стилізуєте на малих екранах
      } else {
        targetMenu.classList.remove('flex'); // Або block
        targetMenu.classList.add('hidden');
      }
    });

    // Додатково: при зміні розміру вікна, якщо він стає великим,
    // переконайтесь, що меню відображається (для lg:flex).
    // Може знадобитися складніша логіка для повного відтворення поведінки Bootstrap.
  }
});

document.addEventListener('turbolinks:before-visit', function() { console.log('Turbolinks: before-visit'); });
document.addEventListener('turbolinks:visit', function() { console.log('Turbolinks: visit'); });
document.addEventListener('turbolinks:load', function() { console.log('Turbolinks: load'); });
document.addEventListener('turbolinks:render', function() { console.log('Turbolinks: render'); });
console.log('io QUI')