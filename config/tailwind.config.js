const defaultTheme = require('tailwindcss/defaultTheme');

module.exports = {
  content: [
    '../app/views/**/*.html.{erb,haml,slim}',
    '../app/helpers/**/*.rb',
    '../app/assets/**/*.{css,js}',
    '../app/components/**/*.{rb,erb}',
    '../app/views/**/*.rb',
    '../config/initializers/**/*.rb',
    '../lib/**/*.rb',
    '../app/javascript/**/*.js',
    '../public/*.html',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        background: 'oklch(1 0 0)',
        foreground: 'oklch(0.145 0 0)',
        card: 'oklch(1 0 0)',
        'card-foreground': 'oklch(0.145 0 0)',
        popover: 'oklch(1 0 0)',
        'popover-foreground': 'oklch(0.145 0 0)',
        primary: 'oklch(0.205 0 0)',
        'primary-foreground': 'oklch(0.985 0 0)',
        secondary: 'oklch(0.97 0 0)',
        'secondary-foreground': 'oklch(0.205 0 0)',
        muted: 'oklch(0.97 0 0)',
        'muted-foreground': 'oklch(0.556 0 0)',
        accent: 'oklch(0.97 0 0)',
        'accent-foreground': 'oklch(0.205 0 0)',
        destructive: 'oklch(0.577 0.245 27.325)',
        'destructive-foreground': 'oklch(0.577 0.245 27.325)',
        border: 'oklch(0.922 0 0)',
        input: 'oklch(0.922 0 0)',
        ring: 'oklch(0.708 0 0)',
      },
      fontFamily: {
        sans: ['system-ui', ...defaultTheme.fontFamily.sans],
      },
      borderRadius: {
        sm: 'calc(0.625rem - 4px)',
        md: 'calc(0.625rem - 2px)',
        lg: '0.625rem',
        xl: 'calc(0.625rem + 4px)',
      },
      container: {
        center: true,
        padding: '2rem',
        screens: {
          lg: '1400px',
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/container-queries'),
    require('tailwind-animate'),
  ],
}