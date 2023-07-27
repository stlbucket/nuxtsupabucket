<template>
  <UCard v-if="!hideNav.all">
    <div v-if="!hideNav.myApp">
      My App
      <MyAppNav/>
    </div>
    <div v-if="!hideNav.myOtherApp">
      My Other App
      <MyOtherAppNav/>
    </div>
    <div>
      Tools
      <ToolsNav />
    </div>
    <div v-if="!hideNav.tenantAdmin">
      Tenant Admin
      <TenantAdminNav />    
    </div>
    <div v-if="!hideNav.siteAdmin">
      Site Admin
      <SiteAdminNav />    
    </div>
  </UCard>
</template>

<script lang="ts" setup>
const supUser = useSupabaseUser()

const hideNav = ref({
  all: false,
  tenantAdmin: false,
  siteAdmin: false,
  myApp: false,
  myOtherApp: false
})

const load = async () => {
  hideNav.value.all = !supUser.value
  hideNav.value.siteAdmin = !supUser.value?.user_metadata?.permissions?.find((p: string) => p.indexOf('p:app-admin-super') > -1)
  hideNav.value.tenantAdmin = !supUser.value?.user_metadata?.permissions?.find((p: string) => p.indexOf('p:app-admin') > -1)
  hideNav.value.myApp = !supUser.value?.user_metadata?.permissions?.find((p: string) => p.indexOf('p:my-app') > -1)
  hideNav.value.myOtherApp = !supUser.value?.user_metadata?.permissions?.find((p: string) => p.indexOf('p:my-other-app') > -1)
}
load()
</script>