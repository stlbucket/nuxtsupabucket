<template>
  <UVerticalNavigation :links="links" />
</template>

<script lang="ts" setup>
const links = [
{
    label: 'Users',
    icon: 'i-heroicons-building-office',
    to: '/admin/app-tenant-user-tenancies'
  },
  {
    label: 'Licenses',
    icon: 'i-heroicons-check-badge',
    to: '/admin/app-tenant-licenses'
  },
  {
    label: 'Subscriptons',
    icon: 'i-heroicons-newspaper',
    to: '/admin/app-tenant-subscriptions'
  },
]
</script>