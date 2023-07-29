<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div>APP TENANTS</div>
        <AppTenantModal @updated="onNewAppTenant"/>
      </div>
    </template>
    <UTable
      :rows="appTenants"
      :columns="[
        {key: 'action'},
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
      <template #action-data="{ row }">
        <UButton @click="onSupport(row)">Support</UButton>
      </template>
    </UTable>
  </UCard>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseAuthClient()
  const appTenants = ref([])
  const loadData = async () => {
    const result = await GqlAllAppTenants()
    appTenants.value = result.allAppTenants.nodes
  }
  loadData()

  const onSupport = async (appTenant: AppTenant) => {
    await GqlBecomeSupport({
      appTenantId: appTenant.id
    })
    reloadNuxtApp({
      path: '/todo',
      force: true
    })    

  }

  const onNewAppTenant = async (createAppTenantInput: any) => {
    await GqlCreateAppTenant(createAppTenantInput)
    await loadData()
  }
</script>
