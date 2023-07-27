<template>
  <UCard>
    <template #header>
      <div>APP TENANT SUBSCRIPTIONS</div>
    </template>
    <UTable
      :rows="appTenantSubscriptions"
      :columns="[
        {key: 'licensePackKey', label: 'License Pack Key', sortable: true}
        ,{key: 'appTenantName', label: 'App Tenant', sortable: true}
      ]"
      :sort="{ column: 'licensePackKey', direction: 'asc' }"
    >
    </UTable>
  </UCard>  
</template>

<script lang="ts" setup>
  const appTenantSubscriptions = ref([])
  const loadData = async () => {
    const result = await GqlAllAppTenantSubscriptions()
    appTenantSubscriptions.value = result.allAppTenantSubscriptions.nodes.map((ats:any) => {
      return {
        ...ats,
        appTenantName: ats.appTenant.name
      }
    })
  }
  loadData()
</script>
