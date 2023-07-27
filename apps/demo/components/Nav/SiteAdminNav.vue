<template>
  <UVerticalNavigation :links="links" />
</template>

<script lang="ts" setup>
const links = [
  {
    label: 'Tenants',
    icon: 'i-heroicons-home',
    to: '/site-admin/app-tenants'
  },
  {
    label: 'License Packs',
    icon: 'i-heroicons-cog-6-tooth',
    to: '/site-admin/license-pack'
  },
  {
    label: 'Users',
    icon: 'i-heroicons-users',
    to: '/site-admin/app-users'
  },
  {
    label: 'User Tenancies',
    icon: 'i-heroicons-building-office',
    to: '/site-admin/app-user-tenancies'
  },
  {
    label: 'Applications',
    icon: 'i-heroicons-cog-6-tooth',
    to: '/site-admin/applications'
  },
]
</script>