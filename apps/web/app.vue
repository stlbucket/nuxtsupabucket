<template>
  <div>
    <NuxtSupaBucketButton @click="getTacos">Tacos</NuxtSupaBucketButton>
  </div>
</template>

<script lang="ts" setup>
  const getTacos = () => {
    alert('oh yeah')
  }
</script>