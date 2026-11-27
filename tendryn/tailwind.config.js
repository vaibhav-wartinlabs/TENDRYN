/**
 * Tendryn design tokens, extracted from the Figma file "Tendryn" (Receptionist page).
 * Source: https://www.figma.com/design/2WJ3m2g9ycodx33rkpWIKn/Tendryn?node-id=108-219
 *
 * Token names mirror the Figma variables (e.g. --color-brand-primary -> `brand-primary`).
 *
 * @type {import('tailwindcss').Config}
 */
module.exports = {
  content: ['./src/**/*.{html,js,jsx,ts,tsx,vue,svelte}', './index.html'],

  theme: {
    // Screens are the design frame widths in the file: mobile 393, tablet 744, desktop 1280.
    // These are inferred from the frames, not defined as Figma variables.
    screens: {
      tablet: '744px',
      desktop: '1280px',
    },

    extend: {
      colors: {
        brand: {
          primary: '#0f766e', // --color-brand-primary
          hover: '#115e59', // --color-brand-hover
          tint: '#e6f4f2', // --color-brand-tint
          DEFAULT: '#0f766e',
        },
        background: {
          app: '#f6faf9', // --color-background-app
          surface: '#ffffff', // --color-background-surface
        },
        text: {
          primary: '#0f1f1d', // --color-text-primary
          secondary: '#5b6b69', // --color-text-secondary
          disabled: '#9aa9a7', // --color-text-disabled
          'on-brand': '#ffffff', // --color-text-on-brand
        },
        border: {
          DEFAULT: '#dde7e5', // --color-border-default
        },
        // Queue priority
        triage: {
          green: '#16a34a', // --color-triage-green
          orange: '#ea580c', // --color-triage-orange
          red: '#dc2626', // --color-triage-red
        },
        // Offline / sync status
        sync: {
          synced: '#16a34a', // --color-sync-synced
          'device-only': '#d97706', // --color-sync-device-only
          'device-only-background': '#fff7e6', // --color-sync-device-only-background (= --sync-amber-background)
        },
        feedback: {
          warning: '#b45309', // --color-feedback-warning
        },
      },

      fontFamily: {
        // Headings
        display: ['"Plus Jakarta Sans"', 'ui-sans-serif', 'system-ui', 'sans-serif'],
        // Body, labels, captions
        sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
      },

      // [size, { lineHeight, fontWeight, letterSpacing }] - letter spacing is 0 for every style.
      fontSize: {
        // Web (tablet + desktop)
        h1: ['2rem', { lineHeight: '2.5rem', fontWeight: '700', letterSpacing: '0' }], // Plus Jakarta Sans Bold 32/40
        h2: ['1.5rem', { lineHeight: '2rem', fontWeight: '600', letterSpacing: '0' }], // Plus Jakarta Sans SemiBold 24/32
        h3: ['1.25rem', { lineHeight: '1.75rem', fontWeight: '600', letterSpacing: '0' }], // Plus Jakarta Sans SemiBold 20/28

        // Mobile
        'h1-mobile': ['1.75rem', { lineHeight: '2.25rem', fontWeight: '700', letterSpacing: '0' }], // Bold 28/36
        'h2-mobile': ['1.375rem', { lineHeight: '1.75rem', fontWeight: '600', letterSpacing: '0' }], // SemiBold 22/28
        'h3-mobile': ['1.125rem', { lineHeight: '1.625rem', fontWeight: '600', letterSpacing: '0' }], // SemiBold 18/26

        // Shared (Inter)
        body: ['1rem', { lineHeight: '1.5rem', fontWeight: '400', letterSpacing: '0' }], // Regular 16/24
        'body-medium': ['1rem', { lineHeight: '1.5rem', fontWeight: '500', letterSpacing: '0' }], // Medium 16/24
        label: ['0.875rem', { lineHeight: '1.25rem', fontWeight: '500', letterSpacing: '0' }], // Medium 14/20 (Web "Label UI" = Mobile "Label Secondary")
        caption: ['0.75rem', { lineHeight: '1rem', fontWeight: '400', letterSpacing: '0' }], // Regular 12/16 ("Caption Meta")
      },

      // Figma spacing variables, by name. Use e.g. p-card-inner, gap-component-gap, px-control-x.
      spacing: {
        'component-gap': '0.5rem', // 8  --space-component-gap
        'card-inner': '1.5rem', // 24 --space-card-inner
        'control-x': '1rem', // 16 --space-control-x
        'control-y': '0.75rem', // 12 --space-control-y
        'status-x': '0.75rem', // 12 --space-status-x
        'status-y': '0.375rem', // 6  --space-status-y
      },

      borderRadius: {
        control: '0.5rem', // 8    --radius-control
        card: '0.75rem', // 12   --radius-card
        pill: '9999px', // --radius-pill
      },

      borderWidth: {
        divider: '1px', // --stroke-divider
        icon: '1.5px', // --stroke-icon (icon stroke weight)
      },

      boxShadow: {
        soft: '0 1px 3px 0 rgb(15 31 29 / 0.08)', // Tendryn/Elevation/Soft (#0F1F1D14, y1, blur 3)
      },

      // Fixed sizes. Use as h-touch-target, min-h-button, h-bottom-nav, h-top-bar, etc.
      height: {
        'touch-target': '3rem', // 48 --size-mobile-touch-target
        button: '3rem', // 48 --size-button-min-height
        'bottom-nav': '4rem', // 64 --size-mobile-bottom-nav
        'top-bar': '4rem', // 64 --size-top-bar
      },
      minHeight: {
        'touch-target': '3rem',
        button: '3rem',
      },
      minWidth: {
        'touch-target': '3rem',
      },
      width: {
        'frame-mobile': '393px', // --frame-mobile-width
        'frame-tablet': '744px', // observed frame width
        sidebar: '248px', // observed desktop "Receptionist navigation" width
      },
      maxWidth: {
        'frame-mobile': '393px',
      },
    },
  },

  plugins: [],
};
