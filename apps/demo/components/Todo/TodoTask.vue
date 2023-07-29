<template>
  <div class="flex justify-start min-w-max border-2 rounded-md border-stone-400 grow">
    <div class="flex flex-col gap-3 align-items-center m-2 basis-1/10">
      <div class="flex gap-1">
        <div class="flex flex-col gap-1 w-30 p-1">
          <div class="flex justify-around gap-1">
            <UButton v-if="todo.status === 'COMPLETE'" icon="i-heroicons-check" size="sm" color="green" square variant="solid" title="Reopen" @click="handleReopen" :disabled="closeDisabled"/>
            <UButton v-if="todo.status === 'INCOMPLETE'" icon="none" size="sm" color="yellow" square variant="outline" title="Close" @click="handleClose" :disabled="closeDisabled"/>
            <TodoModal @updated="handleAddSubtask" :parent-todo="todo"/>
          </div>
          <div class="flex gap-1">
            <TodoModal :todo="todo" @updated="handleUpdated"/>
            <UButton icon="i-heroicons-minus-circle" size="sm" color="red" square variant="solid" title="Delete" @click="handleDelete"/>
          </div>
        </div>
      </div>
    </div>
    <div class="flex flex-1 flex-col m-2 flex-grow-2 gap-1">
      <div class="text-xl flex bg-cyan-950"><NuxtLink :to="`/todo/${todo.id}`">{{ todo.type.split('').at(0) }}: {{ todo.name }}</NuxtLink></div>
      <div class="flex flex-1 gap-2 grow-0" v-if="showOwner">
        <!-- <UButton icon="i-heroicons-user" size="2xs" square variant="outline" title="Close" @click="handleReassign"/> -->
        <TodoAssign :todo="todo" @assigned="handleAssigned" />
        <div>{{ todo.owner?.displayName }}</div>
      </div>
      <div class="flex flex-1" v-if="showDescription"><pre>{{ todo.description }}</pre></div>
    </div>
  </div>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    todo: Todo
  }>()
  const route = useRoute()

  const emit = defineEmits<{
    (e: 'updated', todo?: Todo): void
    (e: 'deleted'): void
  }>()

  const handleUpdated = async (todo: Todo) => {
    const result = await GqlUpdateTodo({
      todoId: todo.id,
      name: todo.name,
      description: todo.description
    })

    emit('updated', result.updateTodo.todo)
  }
  const handleDelete = async () => {
    const confirmed = confirm('Are you sure you want to delete?')
    if (!confirmed) return

    const result = await GqlDeleteTodo({
      todoId: props.todo.id
    })

    emit('deleted')
  }
  const handleAddSubtask = async (subTask: any) => {
    const result = await GqlCreateTodo({
      name: subTask.name,
      description: subTask.description,
      parentTodoId: subTask.parentTodoId
    })
    navigateTo(`/todo/${subTask.parentTodoId}`)
    // emit('updated')
  }
  const handleAssigned = async (appUserTenancyId: string) => {
    const result = await GqlAssignTodo({
      todoId: props.todo.id,
      appUserTenancyId: appUserTenancyId
    })
    emit('updated')
  }
  const handleClose = async () => {
    const result = await GqlUpdateTodoStatus({
      todoId: props.todo.id,
      status: 'COMPLETE'
    })
    emit('updated')
  }
  const handleReopen = async () => {
    const result = await GqlUpdateTodoStatus({
      todoId: props.todo.id,
      status: 'INCOMPLETE'
    })
    emit('updated')
  }
  const handleReassign = async () => {
    alert('not implemented')
  }

  const showOwner = computed(() => {
    return true
  })
  const showDescription = computed(() => {
    return props.todo.id === route.params.id
  })
  const closeDisabled = computed(() => {
    return props.todo?.type !== 'TASK'
  })
</script>