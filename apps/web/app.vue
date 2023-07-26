<template>
  <div>
    <NuxtSupaBucketButton @click="getTacos">Tacos</NuxtSupaBucketButton>
  </div>
</template>

<script lang="ts" setup>
  const getTacos = () => {
    alert('fuck yeah')
  }
</script>