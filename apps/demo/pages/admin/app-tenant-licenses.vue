<template>
  <UCard>
    <template #header>
      <div>LICENSES</div>
    </template>
      <UTable
        :rows="licenses"
        :columns="[
          {key: 'licenseTypeKey', label: 'License Type Key', sortable: true},
          {key: 'email', label: 'Email', sortable: true},
          {key: 'status', label: 'Status', sortable: true},
        ]"
        :sort="{ column: 'appTenantName', direction: 'asc' }"
      >
      </UTable>
  </UCard>
</template>

<script lang="ts" setup>
  const supUser = useSupabaseUser()
  const licenses = ref([])
  const loadData = async () => {
    const result = await GqlAppTenantLicenses({
      appTenantId: supUser.value?.user_metadata.app_tenant_id
    })
    licenses.value = result.appTenantLicenses.nodes.map(l => {
      return {
        ...l,
        status: l.appUserTenancy.status,
        email: l.appUserTenancy.email
      }
    })
  }
  loadData()
</script>
