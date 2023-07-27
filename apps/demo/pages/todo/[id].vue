<template>
  <UCard>
    <template #header>
      <div class="flex flex-col gap-2">
        <div class="flex text-3xl justify-left">{{ todo?.type }}: {{ todo?.name }}</div>
      </div>
    </template>
    <div class="flex flex-col grow">
      <div class="flex justify-stretch grow" v-if="todo?.parent?.parent"><TodoTask :todo="todo.parent.parent" /></div>
      <div class="flex pl-3 grow" v-if="todo?.parent"><TodoTask :todo="todo.parent" /></div>
      <div class="flex pl-6"><TodoListManager :todo="todo" @updated="onUpdated" @deleted="onDeleted"></TodoListManager></div>
    </div>
  </UCard>
</template>

<script lang="ts" setup>
  const route = useRoute()
  const todo = ref()

  const loadData = async () => {
    const result = await GqlTodoById({
      id: route.params.id,
    })
    todo.value = result.todoById
  }
  loadData()

  const onUpdated = async () => {
    await loadData()
  }
  const onDeleted = async () => {
    await loadData()
  }

</script>
