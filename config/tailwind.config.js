const defaultTheme = require('tailwindcss/defaultTheme');

module.exports = {
  content: [
    '../app/views/**/*.html.{erb,haml,slim}', // Стандартні шляхи Rails views
    '../app/helpers/**/*.rb', // Хелпери Rails
    '../app/assets/**/*.{css,js}', // Асети JS/CSS
    '../app/components/**/*.{rb,erb}', // Шлях до ваших Phlex компонентів (.rb та .erb, якщо є)
    '../app/views/**/*.rb', // Шлях до ваших Phlex View-класів (якщо вони в app/views)
    '../config/initializers/**/*.rb', // Ініціалізатори (якщо класи використовуються там)
    '../lib/**/*.rb', // Lib файли (якщо класи використовуються там)
    '../app/javascript/**/*.js',
    '../public/*.html',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans], // Приклад використання кастомного шрифту Inter
      },
      // Тут ви можете додати свої власні кольори, відступи, розміри шрифтів тощо.
      // Приклад:
      // colors: {
      //   'custom-blue': '#1a2b3c',
      // },
      // spacing: {
      //   '128': '32rem',
      // },
    },
  },
  plugins: [
    require('@tailwindcss/forms'), // Якщо ви використовуєте плагін форм
    require('@tailwindcss/typography'), // Якщо ви використовуєте плагін typography
    // Додайте інші плагіни Tailwind тут, які ви використовуєте (наприклад, з вашого application.tailwind.css)
    // require('@tailwindcss/aspect-ratio'),
    // require('@tailwindcss/container-queries'),
  ],
}