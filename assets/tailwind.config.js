const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: ["../lib/*_web/**/*.*ex", "./js/*.js"],
  theme: {    
    backgroundSize: {
      'auto': 'auto',
      'cover': 'cover',
      'contain': 'contain',
      '10%': '10%',
      '50%': '50%',
      '80%': '80%',
      '90%': '90%',
      '100%': '100%',
      '16': '4rem',
    },
    screens: {
      'xs': '480px',
      // => @media (min-width: 640px) { ... }

      'sm': '540px',
      // => @media (min-width: 640px) { ... }

      'md': '768px',
      // => @media (min-width: 768px) { ... }

      'md-lg': '900px',
      // => @media (min-width: 1024px) { ... }

      'lg': '1024px',
      // => @media (min-width: 1024px) { ... }

      'xl': '1280px',
      // => @media (min-width: 1280px) { ... }

      '2xl': '1536px',
      // => @media (min-width: 1536px) { ... }
    },
    extend: {
      textColor: {
        'topbar': '#E6E6E6'
      },
      backgroundColor: {
        'main': '#242526'
      },
      grayscale:{
        50: '50%', 
        75: '75%'
      },
      height: {
        'calc-vh1': 'calc(-84px + 100vh)',
        'calc-vh2': 'calc(-56px + 100vh)'
      },
      minHeight: {
        'calc-vh1': 'calc(-84px + 100vh)',
        'calc-vh2': 'calc(-56px + 100vh)'
      }
    },
  },
  plugins: [require('@tailwindcss/aspect-ratio')],
}
