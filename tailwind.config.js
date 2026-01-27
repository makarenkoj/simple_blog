module.exports = {
  content: [
    './app/assets/stylesheets/**/*.css',
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/components/**/*.{rb,erb,html}'
  ],

  theme: {
    extend: {},
  },
  safelist: [
    {
      pattern: /bg-(red|green|blue|yellow|gray)-(100|400|700)/,
    },
    {
      pattern: /text-(red|green|blue|yellow|gray)-(700)/,
    },
    {
      pattern: /border-(red|green|blue|yellow|gray)-(400)/,
    }
  ],
  
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
