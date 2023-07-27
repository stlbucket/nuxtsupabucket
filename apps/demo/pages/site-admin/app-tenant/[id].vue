<template>
  <UCard v-if="appTenant">
    <template #header>
      <div class="text-2xl">{{ appTenant.name }}</div>
    </template>
    <div class="flex justify-start gap-5">
      <div class="flex flex-col gap-1 bg-cyan-700 p-3">
        <div class="flex text-xs">Status</div>
        <div class="flex">{{ appTenant.status }}</div>
      </div>
      <div class="flex flex-col gap-1 bg-cyan-700 p-3">
        <div class="flex text-xs">Type</div>
        <div class="flex">{{ appTenant.type }}</div>
      </div>
    </div>
    <UCard>
      <UTable
        :rows="appTenant.appTenantSubscriptions"
        :columns="[
          {key: 'licensePackKey', label: 'License Pack'},
          {key: 'createdAt', label: 'Subscribed at'},
          {key: 'licenseTypes', label: 'License Types'}
        ]"
      >
      <template #createdAt-data="{ row }">
        {{ useFormatDateTimeString(row.createdAt) }}
      </template>
      <template #licenseTypes-data="{ row }">
        <UBadge v-for="lt in row.licensePack.licenseTypes">{{ lt.licenseTypeKey }}</UBadge>
      </template>
    </UTable>
    </UCard>
  </UCard>
  <pre>{{ JSON.stringify(appTenant,null,2) }}</pre>
</template>

<script lang="ts" setup>
  const route = useRoute()
  const appTenant = ref()

  const loadData = async () => {
    const result = await GqlAppTenantById({
      appTenantId: route.params.id,
    })
    appTenant.value = result.appTenantById
  }
  loadData()

  // const handleUpdateAppTenantStatus = async (updatedappTenant: AppTenant) => {
  //   appTenant.value = updatedAppTenant
  // }
  </script>
