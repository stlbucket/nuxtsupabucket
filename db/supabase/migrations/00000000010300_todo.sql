-----------------------------------------------
-- script  todo schema
-----------------------------------------------
create schema if not exists todo;
create schema if not exists todo_fn;
-----------------------------------------------
create type todo.todo_status as enum (
  'incomplete'
  ,'complete'
  ,'archived'
  ,'unfinished'
);
-----------------------------------------------
create type todo.todo_type as enum (
  'task'
  ,'milestone'
  ,'project'
);
-----------------------------------------------
create type app_fn.paging_options as (
  item_offset integer
  ,page_offset integer
  ,item_limit integer
);
-----------------------------------------------
create type todo_fn.search_todos_options as (
  search_term citext
  ,todo_type todo.todo_type
  ,todo_status todo.todo_status
  ,roots_only boolean
  ,paging_options app_fn.paging_options
);
------------------------------------------------------------------------ todo
create table if not exists todo.todo (
  id uuid NOT NULL DEFAULT gen_random_uuid() primary key
  ,project_todo_id uuid null references todo.todo(id)
  ,parent_todo_id uuid null references todo.todo(id)
  ,app_tenant_id uuid not null references app.app_tenant(id)
  ,app_user_tenancy_id uuid not null references app.app_user_tenancy(id)
  ,created_at timestamptz not null default current_timestamp
  ,updated_at timestamptz not null default current_timestamp
  ,name citext not null
  ,description citext
  ,status todo.todo_status not null default 'incomplete'
  ,check(char_length(name) >= 3)
  ,type todo.todo_type not null default 'task'
  ,ordinal integer not null
  ,pinned boolean not null default false
);
-----------------------------------------------
 create index idx_todo_todo_project_todo_id on todo.todo(project_todo_id);
 create index idx_todo_todo_app_tenant_id on todo.todo(app_tenant_id);
 create index idx_todo_todo_app_user_tenancy_id on todo.todo(app_user_tenancy_id);
 create index idx_todo_todo_parent_todo_id on todo.todo(parent_todo_id);
