------------------------ CREATE ANCHOR TENANT AND SUPER ADMIN USER ---------------------------------------------
--- change parameters as appropriate

  select app_fn.create_anchor_tenant(
    _name => 'Anchor Tenant'::citext
    ,_email => 'app-admin-super@example.com'::citext
  );


------------------------ INSTALL APPLICATIONS ------------------------------

  select my_app_fn.install_my_application();
  select my_other_app_fn.install_my_other_application();

------------------------------------------------------------------------------------------------------------
------------------------------------- DEMO AND INITIAL TENANTS -------------------------------------------------
--
-- These app_tenants and users are to support local development as they are currently configured. They are
-- used in conjuction with the DemoAppUserTenancies component to allow for quick context switching between
-- tenants and users in conjunction with the Inbucket service
-- 
-- When starting a new project, these can all be leveraged for unit tests and for local UI development
--
-- When deploying to an initial prototype environment (maybe your free project), these can be changed
-- to actual users to allow for easy rebasing of the entire database while maintaining a core set of users.
--
-- Usage in other environments is at the discretion of the developer

-- Note that changes to these demo tenants will break unit tests that check for these to be here
-- those tests can be commented out, adjusted, or deleted as appropriate

-------------------------------  DEMO TENANT 1

select app_fn.invite_user(
  _app_tenant_id => (select id from app.app_tenant where identifier = 'anchor')::uuid
  ,_email => 'anchor-tenant-admin@example.com'::citext
  ,_permission_level => 'admin'::app.license_type_permission_level
);
select app_fn.invite_user(
  _app_tenant_id => (select id from app.app_tenant where identifier = 'anchor')::uuid
  ,_email => 'anchor-tenant-user@example.com'::citext
  ,_permission_level => 'user'::app.license_type_permission_level
);


-------------------------------  DEMO TENANT 1

select app_fn.create_app_tenant(
  _name =>'Demo Tenant 1'::citext
  ,_identifier =>'demo-tenant-1'::citext
  ,_email => 'demo-tenant-1-admin@example.com'::citext
  , _type => 'demo'::app.app_tenant_type
);
select app_fn.subscribe_tenant_to_license_pack(
  _app_tenant_id => (select id from app.app_tenant where identifier = 'demo-tenant-1')::uuid
  ,_license_pack_key => 'my-app'
);
select app_fn.invite_user(
  _app_tenant_id => (select id from app.app_tenant where identifier = 'demo-tenant-1')::uuid
  ,_email => 'demo-tenant-1-user-1@example.com'::citext
  ,_permission_level => 'user'::app.license_type_permission_level
);
select app_fn.invite_user(
  _app_tenant_id => (select id from app.app_tenant where identifier = 'demo-tenant-1')::uuid
  ,_email => 'demo-tenant-1-user-2@example.com'::citext
  ,_permission_level => 'user'::app.license_type_permission_level
);

-------------------------------  DEMO TENANT 2
select app_fn.create_app_tenant(
  _name =>'Demo Tenant 2'::citext
  ,_identifier =>'demo-tenant-2'::citext
  ,_email => 'demo-tenant-2-admin@example.com'::citext
  , _type => 'demo'::app.app_tenant_type
);
select app_fn.subscribe_tenant_to_license_pack(
  _app_tenant_id => (select id from app.app_tenant where identifier = 'demo-tenant-2')::uuid
  ,_license_pack_key => 'my-other-app'
);
select app_fn.invite_user(
  _app_tenant_id => (select id from app.app_tenant where identifier = 'demo-tenant-2')::uuid
  ,_email => 'demo-tenant-2-user-1@example.com'::citext
  ,_permission_level => 'user'::app.license_type_permission_level
);
select app_fn.invite_user(
  _app_tenant_id => (select id from app.app_tenant where identifier = 'demo-tenant-2')::uuid
  ,_email => 'demo-tenant-2-user-2@example.com'::citext
  ,_permission_level => 'user'::app.license_type_permission_level
);
------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------
-- TODO DEMO DATA
select todo_fn.create_todo(
  _app_tenant_id => (select id from app.app_tenant where type = 'anchor')::uuid
  ,_app_user_tenancy_id => (
    select id from app.app_user_tenancy 
    where email = 'app-admin-super@example.com'
    and app_tenant_name = 'Anchor Tenant'
  )::uuid
  ,_name => 'Anchor Super Admin Todo List'::citext
  ,_description => 'Demo Todo List'
);  

--------------------- DEMO TENANT 1 LISTS
select todo_fn.create_todo(
  _app_tenant_id => (select id from app.app_tenant where name = 'Demo Tenant 1')::uuid
  ,_app_user_tenancy_id => (
    select id from app.app_user_tenancy 
    where email = 'demo-tenant-1-admin@example.com'
    and app_tenant_name = 'Demo Tenant 1'
  )::uuid
  ,_name => 'Tenant 1 Admin Todo List'::citext
  ,_description => 'Demo Todo List'
);  
select todo_fn.create_todo(
  _app_tenant_id => (select id from app.app_tenant where name = 'Demo Tenant 1')::uuid
  ,_app_user_tenancy_id => (
    select id from app.app_user_tenancy 
    where email = 'demo-tenant-1-user-1@example.com'
    and app_tenant_name = 'Demo Tenant 1'
  )::uuid
  ,_name => 'Tenant 1 User 1 Todo List'::citext
  ,_description => 'Demo Todo List'
);  
select todo_fn.create_todo(
  _app_tenant_id => (select id from app.app_tenant where name = 'Demo Tenant 1')::uuid
  ,_app_user_tenancy_id => (
    select id from app.app_user_tenancy 
    where email = 'demo-tenant-1-user-2@example.com'
    and app_tenant_name = 'Demo Tenant 1'
  )::uuid
  ,_name => 'Tenant 1 User 2 Todo List'::citext
  ,_description => 'Demo Todo List'
);  
  
--------------------- DEMO TENANT 1 LISTS
select todo_fn.create_todo(
  _app_tenant_id => (select id from app.app_tenant where name = 'Demo Tenant 2')::uuid
  ,_app_user_tenancy_id => (
    select id from app.app_user_tenancy 
    where email = 'demo-tenant-2-admin@example.com'
    and app_tenant_name = 'Demo Tenant 2'
  )::uuid
  ,_name => 'Tenant 2 Admin Todo List'::citext
  ,_description => 'Demo Todo List'
);  
select todo_fn.create_todo(
  _app_tenant_id => (select id from app.app_tenant where name = 'Demo Tenant 2')::uuid
  ,_app_user_tenancy_id => (
    select id from app.app_user_tenancy 
    where email = 'demo-tenant-2-user-1@example.com'
    and app_tenant_name = 'Demo Tenant 2'
  )::uuid
  ,_name => 'Tenant 2 User 1 Todo List'::citext
  ,_description => 'Demo Todo List'
);  
    select todo_fn.create_todo(
      _app_tenant_id => (select id from app.app_tenant where name = 'Demo Tenant 2')::uuid
      ,_app_user_tenancy_id => (
        select id from app.app_user_tenancy 
        where email = 'demo-tenant-2-user-1@example.com'
        and app_tenant_name = 'Demo Tenant 2'
      )::uuid
      ,_name => 'Tenant 2 User 2 Todo List Item'::citext
      ,_description => 'Demo Todo List Item 1'
      ,_parent_todo_id => (select id from todo.todo where name = 'Tenant 2 User 1 Todo List')
    );  
    
    select todo_fn.create_todo(
      _app_tenant_id => (select id from app.app_tenant where name = 'Demo Tenant 2')::uuid
      ,_app_user_tenancy_id => (
        select id from app.app_user_tenancy 
        where email = 'demo-tenant-2-user-1@example.com'
        and app_tenant_name = 'Demo Tenant 2'
      )::uuid
      ,_name => 'Tenant 2 User 2 Todo List Item'::citext
      ,_description => 'Demo Todo List Item 2'
      ,_parent_todo_id => (select id from todo.todo where name = 'Tenant 2 User 1 Todo List')
    );  
    
------------------------------------------------------------------------
select todo_fn.create_todo(
  _app_tenant_id => (select id from app.app_tenant where name = 'Demo Tenant 2')::uuid
  ,_app_user_tenancy_id => (
    select id from app.app_user_tenancy 
    where email = 'demo-tenant-2-user-2@example.com'
    and app_tenant_name = 'Demo Tenant 2'
  )::uuid
  ,_name => 'Tenant 2 User 2 Todo List'::citext
  ,_description => 'Demo Todo List'
);  
    select todo_fn.create_todo(
      _app_tenant_id => (select id from app.app_tenant where name = 'Demo Tenant 2')::uuid
      ,_app_user_tenancy_id => (
        select id from app.app_user_tenancy 
        where email = 'demo-tenant-2-user-2@example.com'
        and app_tenant_name = 'Demo Tenant 2'
      )::uuid
      ,_name => 'Tenant 2 User 2 Todo List Item'::citext
      ,_description => 'Demo Todo List Item'
      ,_parent_todo_id => (select id from todo.todo where name = 'Tenant 2 User 2 Todo List')
    );  
    
------------------------------------------------------------------------------------------------------------
