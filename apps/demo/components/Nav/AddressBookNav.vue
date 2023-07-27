<template>
  <UVerticalNavigation :links="links" />
</template>

<script lang="ts" setup>
const links = [
  {
    label: 'Address Book',
    icon: 'i-heroicons-book-open',
    to: '/address-book'
  }
]
</script>