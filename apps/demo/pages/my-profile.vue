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
    <pre>{{ JSON.stringify(supUser,null,2) }}</pre>
</template>

<script lang="ts" setup>
  const supUser = useSupabaseUser()

</script>
