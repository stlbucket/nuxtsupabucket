<template>
  <div class="flex flex-col gap-1">
    <TodoTask v-for="t in todos" :todo="t" @updated="onUpdated" @deleted="onDeleted"></TodoTask>
  </div>
</template>

<script lang="ts" setup>
  export type TodoStatus = 'complete' | 'incomplete' | 'archived'
  export interface Props {
    status: TodoStatus,
    todos: any[]
  }
  const props = defineProps<Props>()

  const emit = defineEmits<{
    (e: 'updated'): void
    (e: 'deleted'): void
  }>()
  const onUpdated = async () => {
    emit('updated')
  }
  const onDeleted = async () => {
    emit('deleted')
  }

</script>