<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div>APP USERS</div>
      </div>
    </template>
    <UTable
      :rows="appUsers"
      :columns="[
        {key: 'email', label: 'Email', sortable: true},
        {key: 'firstName', label: 'First Name', sortable: true},
        {key: 'lastName', label: 'Last Name', sortable: true},
        {key: 'status', label: 'Status', sortable: true},
        {key: 'licenses', sortable: true}
      ]"
      :sort="{ column: 'name', direction: 'asc' }"
    >
      <template #licenses-data="{ row }">
        {{ `${row.appUserTenancies.length} Tenanc${row.appUserTenancies.length > 1 ? 'ies' : 'y'}` }}
      </template>
    </UTable>
  </UCard>  
</template>

<script lang="ts" setup>
  const appUsers = ref([])
  const loadData = async () => {
    const result = await GqlAllAppUsers()
    appUsers.value = result.allAppUsers.nodes
  }
  loadData()
</script>
