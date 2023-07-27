<template>
  <div v-if="todo" class="flex flex-col grow">
    <TodoTask 
      :todo="todo"
      @updated="onUpdated"
    ></TodoTask>
    <div class="flex justify-stretch grow gap-1 mt-3" v-if="todo.type !== 'TASK'">
      <div class="flex flex-col gap-1 grow max-w-[50%] overflow-hidden">
        <div class="text-xl">INCOMPLETE SUBTASKS</div>
        <TodoList
          status="incomplete"
          :todos="incompleteTodos"
          @updated="onUpdated"
          @deleted="onDeleted"
        />
      </div>
      <div class="flex flex-col gap-1 grow max-w-[50%] overflow-hidden">
        <div class="text-xl">COMPLETE SUBTASKS</div>
        <TodoList
          status="complete"
          :todos="completeTodos"
          @updated="onUpdated"
        />
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    todo: Todo
  }>()

  const incompleteTodos = ref([])
  const completeTodos = ref([])

  const sortTodos = async () => {
    if (props.todo) {
      incompleteTodos.value = props.todo.children.filter((t:any) => t.status === 'INCOMPLETE')
      completeTodos.value = props.todo.children.filter((t:any) => t.status === 'COMPLETE')
    }
  }
  watch(() => props.todo, async () => {
    await sortTodos()
  })

  const emit = defineEmits<{
    (e: 'updated'): void,
    (e: 'deleted'): void
  }>()
  const onUpdated = async () => {
    emit('updated')
  }
  const onDeleted = async () => {
    emit('deleted')
  }

</script>