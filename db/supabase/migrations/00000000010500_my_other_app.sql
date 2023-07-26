-----------------------------------------------
create schema if not exists my_other_app;
create schema if not exists my_other_app_fn;
create schema if not exists my_other_app_fn_api;
-----------------------------------------------
create table if not exists my_other_app.my_data_point (
  id uuid NOT NULL DEFAULT gen_random_uuid() primary key
  ,app_tenant_id uuid not null references app.app_tenant(id)
  ,app_user_tenancy_id uuid not null references app.app_user_tenancy(id)
  ,created_at timestamptz not null default current_timestamp
  ,data citext
);
