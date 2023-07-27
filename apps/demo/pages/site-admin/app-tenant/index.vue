<template>
  <UCard>
    <template #header>
      <div>APP-TENANTS</div>
    </template>
    <UTable
      :rows="appTenants"
      :columns="[
        // {key: 'id', label: 'Name'},
        {key: 'name', label: 'Name', sortable: true},
        {key: 'status', label: 'Status', sortable: true},
        {key: 'type', label: 'Type', sortable: true},
        {key: 'identifier', label: 'Identifier', sortable: true},
        {key: 'subscriptions', label: 'Subscriptions', sortable: true},
      ]"
      :sort="{ column: 'name', direction: 'asc' }"
    >
      <template #name-data="{ row }">
        <NuxtLink :to="`/site-admin/app-tenant/${row.id}`">{{ row.name }}</NuxtLink>
      </template>
      <template #subscriptions-data="{ row }">
        <UBadge v-for="ats in row.appTenantSubscriptions">{{ ats.licensePackKey }}</UBadge>
      </template>
    </UTable>
  </UCard>
</template>

<script lang="ts" setup>
  const appTenants = ref([])
  const loadData = async () => {
    const result = await GqlAllAppTenants()
    appTenants.value = result.allAppTenants.nodes
  }
  loadData()
</script>
