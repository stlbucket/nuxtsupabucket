<template>
  <UVerticalNavigation :links="links" />
</template>

<script lang="ts" setup>
const links = [
{
    label: 'Other Data Points',
    icon: 'i-heroicons-book-open',
    to: '/my-other-app'
  },
]
</script>