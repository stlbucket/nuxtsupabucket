<template>
  <UCard>
    <template #header>License Types</template>
    <UTable
      :rows="sorted"
      :columns="[
        {key: 'issuedCount', label: '# Issued'},
        {key: 'licenseTypeKey', label: 'Key'},
        {key: 'permissionLevel', label: 'Permission Level'},
        {key: 'expirationInterval', label: 'Expiration'},
        {key: 'permissions', label: 'Permissions'},        
      ]"
    >
      <template #expirationInterval-data="{ row }">
        <UBadge v-if="row.expirationIntervalType === 'NONE'">NONE</UBadge>
        <UBadge v-if="row.expirationIntervalType !== 'NONE' && row.expirationIntervalMultiplier === 0">UNLIMITED</UBadge>
        <UBadge v-if="row.expirationIntervalType !== 'NONE' && row.expirationIntervalMultiplier === 1">{{`${row.expirationIntervalMultiplier} ${row.expirationIntervalType}`}}</UBadge>
        <UBadge v-if="row.expirationIntervalType !== 'NONE' && row.expirationIntervalMultiplier > 1">{{`${row.expirationIntervalMultiplier} ${row.expirationIntervalType}S`}}</UBadge>
      </template>
      <template #permissionLevel-data="{ row }">
        <UBadge>{{ row.licenseType.permissionLevel }}</UBadge>
      </template>
      <template #permissions-data="{ row }">
        <UBadge v-for="p in row.licenseType.permissions">{{ p.permissionKey }}</UBadge>
      </template>
    </UTable>
    <!-- <pre>{{ licensePackLicenseTypes }}</pre> -->
  </UCard>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    licensePackLicenseTypes: []
  }>()

  const sorted = computed(() => {
    return props.licensePackLicenseTypes.sort((a,b) => a.licenseTypeKey < b.licenseTypeKey ? -1 : 1)
  })
</script>
