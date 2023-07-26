import DefaultTheme from 'vitepress/theme'
import MyButton from '@nuxtsupabucket/ui/components/Button.vue'

export default {
  ...DefaultTheme,
  enhanceApp({ app }) {
    app.component('MyButton', MyButton)
  },
}
