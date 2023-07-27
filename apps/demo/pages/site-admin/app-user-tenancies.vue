<template>
    <AppUserTenancies title="ALL TENANCIES" :tenancies="tenancies"/>
</template>

<script lang="ts" setup>
  const tenancies = ref([])
  const loadTenancies = async () => {
    const result = await GqlAllAppUserTenancies()
    tenancies.value = result.allAppUserTenancies.nodes || []
  }
  loadTenancies()

  const onNew = async () => {
    alert('not implemented')
  }
</script>