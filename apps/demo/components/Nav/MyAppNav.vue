<template>
  <UVerticalNavigation :links="links" />
</template>

<script lang="ts" setup>
const links = [
{
    label: 'Data Points',
    icon: 'i-heroicons-book-open',
    to: '/my-app'
  },
]
</script>