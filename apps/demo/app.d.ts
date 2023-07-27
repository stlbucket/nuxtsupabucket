// https://www.reddit.com/r/Supabase/comments/155nz4m/introspect_postgresql_schema_and_generate/

import { Database } from "./lib/database.types"

declare global {
  type Application = Database['app']['Tables']['application']['Row']
  type LicensePack = Database['app']['Tables']['license_pack']['Row']
  type AppTenant = Database['app']['Tables']['app_tenant']['Row']
  type AppTenantSubscription = Database['app']['Tables']['app_tenant_subscription']['Row']
  type AppUser = Database['app']['Tables']['app_user']['Row']
  type AppUserTenancy = Database['app']['Tables']['app_user_tenancy']['Row']
  
  type Todo = Database['todo']['Tables']['todo']['Row']
    
}


// type LicenseType = Database['app']['Tables']['license_type']['Row']
// type License = Database['app']['Tables']['license']['Row']
// type LicensePackLicenseType = Database['app']['Tables']['license_pack_license_type']['Row']
