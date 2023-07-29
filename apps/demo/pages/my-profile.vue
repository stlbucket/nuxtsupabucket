<template>
    <div class="flex">
      <div>
        <MyAppUserTenancies />
      </div>
      <div>
        <Myself />
      </div>
      <div>
      </div>
    </div>
    <!-- <pre>{{ JSON.stringify(supUser,null,2) }}</pre> -->
    <pre>{{ JSON.stringify(currentAppUser,null,2) }}</pre>
</template>

<script lang="ts" setup>
  const supUser = useSupabaseUser()
  const currentAppUser = ref()

  const loadData = async () => {
    const {data,error} = await useFetch('/api/current-app-user')
    if (error.value) {
      alert(error.value?.message)
    }
    currentAppUser.value = data.value
  }
  loadData()
</script>
