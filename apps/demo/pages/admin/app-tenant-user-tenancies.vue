<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div>APP USERS</div>
        <UButton @click="onNew">Invite</UButton>
      </div>
    </template>
    <AppUserTenancies :tenancies="tenancies"/>
  </UCard>
</template>

<script lang="ts" setup>
  const tenancies = ref([])
  const loadTenancies = async () => {
    const result = await GqlAppTenantAppUserTenancies()
    tenancies.value = result.appTenantAppUserTenancies.nodes || []
  }
  loadTenancies()

  const onNew = async () => {
    alert('not implemented')
  }
</script>