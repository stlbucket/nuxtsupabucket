<template>
  <UTable
    :rows="tenancies"
    :columns="[
      {key: 'actions'},
      {key: 'email', label: 'Email', sortable: true},
      {key: 'status', label: 'Status', sortable: true},
      {key: 'appTenantName', label: 'Tenant', sortable: true},
    ]"
    :sort="{ column: 'appTenantName', direction: 'asc' }"
  >
    <template #actions-data="{ row }">
      <UButton v-if="rowActionName" @click="handleRowAction(row)">{{rowActionName}}</UButton>
    </template>
  </UTable>
</template>

<script lang="ts" setup>
  defineProps<{
    tenancies: any[]
    rowActionName?: string
  }>()

  const emit = defineEmits<{
    (e: 'rowAction', row: any): void
  }>()

  const handleRowAction = async (row: any) => {
    emit('rowAction', row)
  }
</script>