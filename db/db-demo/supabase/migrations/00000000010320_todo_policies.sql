-- todo_fn_api
grant usage on schema todo_fn_api to anon, authenticated, service_role;
grant all on all tables in schema todo_fn_api to anon, authenticated, service_role;
grant all on all routines in schema todo_fn_api to anon, authenticated, service_role;
grant all on all sequences in schema todo_fn_api to anon, authenticated, service_role;
alter default privileges for role postgres in schema todo_fn_api grant all on tables to anon, authenticated, service_role;
alter default privileges for role postgres in schema todo_fn_api grant all on routines to anon, authenticated, service_role;
alter default privileges for role postgres in schema todo_fn_api grant all on sequences to anon, authenticated, service_role;

-- todo_fn
grant usage on schema todo_fn to anon, authenticated, service_role;
grant all on all tables in schema todo_fn to anon, authenticated, service_role;
grant all on all routines in schema todo_fn to anon, authenticated, service_role;
grant all on all sequences in schema todo_fn to anon, authenticated, service_role;
alter default privileges for role postgres in schema todo_fn grant all on tables to anon, authenticated, service_role;
alter default privileges for role postgres in schema todo_fn grant all on routines to anon, authenticated, service_role;
alter default privileges for role postgres in schema todo_fn grant all on sequences to anon, authenticated, service_role;

--- todo policies
grant usage on schema todo to anon, authenticated, service_role;
grant all on all tables in schema todo to anon, authenticated, service_role;
grant all on all routines in schema todo to anon, authenticated, service_role;
grant all on all sequences in schema todo to anon, authenticated, service_role;
alter default privileges for role postgres in schema todo grant all on tables to anon, authenticated, service_role;
alter default privileges for role postgres in schema todo grant all on routines to anon, authenticated, service_role;
alter default privileges for role postgres in schema todo grant all on sequences to anon, authenticated, service_role;


------------------------------------------------------------------------ todo
alter table todo.todo enable row level security;
    CREATE POLICY manage_all_for_tenant ON todo.todo
      FOR ALL
      USING (auth_ext.app_tenant_id()::uuid = app_tenant_id)
      WITH CHECK (auth_ext.app_tenant_id()::uuid = app_tenant_id)
      ;

    CREATE POLICY manage_all_support ON todo.todo
      FOR ALL
      USING (auth_ext.has_permission('p:app-admin-support'))
      WITH CHECK (auth_ext.has_permission('p:app-admin-support'))
      ;
