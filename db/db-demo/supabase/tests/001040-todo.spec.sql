BEGIN;
-- SELECT plan(7);
SELECT * FROM no_plan();

-- Examples: https://pgtap.org/documentation.html
\set _app_tenant_name 'todo-test-tenant'
\set _app_tenant_admin_email 'todo-test-tenant1-admin@example.com'
-- \set _license_pack_key 'todo'
\set _identifier 'todo-test-tenant'
------------------------------------------------------------------------
-- SETUP TEST TENANT
------------------------------------------------------------------------ 
  select isa_ok(
    (select app_fn.create_app_tenant(
      :'_app_tenant_name'::citext
      ,:'_identifier'::citext
      ,:'_app_tenant_admin_email'::citext
    ))
    ,'app.app_tenant'
    ,'should create an app_tenant'
  );
  -- select isa_ok(
  --   (select app_fn.subscribe_tenant_to_license_pack(
  --     _app_tenant_id => (select id from app.app_tenant where name = :'_app_tenant_name'::citext)
  --     ,_license_pack_key => :'_license_pack_key'::citext
  --   ))
  --   ,'app.app_tenant_subscription'
  --   ,'should subscribe tenant to license pack'
  -- );
  select isa_ok(
    test_helpers.create_supabase_user(
      _email => :'_app_tenant_admin_email'::text
      ,_user_metadata => '{"test": "meta"}'::jsonb
      ,_password => 'badpassword'
    )
    ,'uuid'
    ,'create_supabase_user should return uuid'
  );
  select test_helpers.login_as_user(
    _email => :'_app_tenant_admin_email'::citext
  );
  select isa_ok(
    app_fn.assume_app_user_tenancy(
      _app_user_tenancy_id => (select id from app.app_user_tenancy where email = :'_app_tenant_admin_email'::citext)
      ,_email => :'_app_tenant_admin_email'::citext
    )
    ,'app.app_user_tenancy'
    ,'should assume the tenancy'
  );
  select test_helpers.logout();
------------------------------------------------------------------------
-- END SETUP TEST TENANT
------------------------------------------------------------------------ 

------------------------------------------------------------------------ 
-- EXERCISE TODO FUNCTIONS
------------------------------------------------------------------------ 
  \set _todo_list_name "test todo name"
  \set _todo_name_1 "test todo 1"
  \set _todo_name_2 "test todo 2"

  select test_helpers.login_as_user(
    _email => :'_app_tenant_admin_email'::citext
  );
  ------------------------------------ test permissions
  select is(
    (select auth_ext.has_permission('p:app'))
    ,true
    ,'_app_tenant_admin_email user should have app permission'
  );
  ------------------------------------ test permissions
  select is(
    (select auth_ext.has_permission('p:app-admin'))
    ,true
    ,'_app_tenant_admin_email user should have p:app-admin permission'
  );
  ------------------------------------ test permissions
  select is(
    (select auth_ext.has_permission('p:app-admin-super'))
    ,false
    ,'_app_tenant_admin_email user should not have p:app-admin-super permission'
  );
  ------------------------------------------------------------------------ 
  select isa_ok(
    (
      select todo_fn_api.create_todo(
        _name => :'_todo_list_name'::citext
      )
    )
    ,'todo.todo'
    ,'should create a todo'
  );
      select isa_ok(
        (select id from todo.todo where name = :'_todo_list_name'::citext)::uuid
        ,'uuid'
        ,'todo_list id should be uuid'
      );
      select is(
        (select status from todo.todo where name = :'_todo_list_name'::citext)::todo.todo_status
        ,'incomplete'::todo.todo_status
        ,'todo list status should be incomplete'
      );
      select is(
        (select type from todo.todo where name = :'_todo_list_name'::citext)::todo.todo_type
        ,'task'::todo.todo_type
        ,'todo list type should be task'
      );
  ------------------------------------------------------------------------ 
  select isa_ok(
    (
      select todo_fn_api.create_todo(
        _name => :'_todo_name_1'::citext
        ,_parent_todo_id => (select id from todo.todo where name = :'_todo_list_name'::citext)
      )
    )
    ,'todo.todo'
    ,'should create a todo'
  );
      select isa_ok(
        (select id from todo.todo where name = :'_todo_name_1'::citext)
        ,'uuid'
        ,'todo 1 id should be uuid'
      );
      select is(
        (select status from todo.todo where name = :'_todo_name_1'::citext)::todo.todo_status
        ,'incomplete'::todo.todo_status
        ,'todo status should be incomplete'
      );
      select is(
        (select type from todo.todo where name = :'_todo_list_name'::citext)::todo.todo_type
        ,'project'::todo.todo_type
        ,'todo list type should be project'
      );
      select isa_ok(
        (select todo_fn.pin_todo(id) from todo.todo where name = :'_todo_name_1'::citext)::todo.todo
        ,'todo.todo'
        ,'todo pin todo'
      );
      select is(
        (select pinned from todo.todo where name = :'_todo_name_1'::citext)::boolean
        ,true
        ,'todo should be pinned'
      );
      select isa_ok(
        (select todo_fn.unpin_todo(id) from todo.todo where name = :'_todo_name_1'::citext)::todo.todo
        ,'todo.todo'
        ,'todo unpin todo'
      );
      select is(
        (select pinned from todo.todo where name = :'_todo_name_1'::citext)::boolean
        ,false
        ,'todo should be unpinned'
      );
  ------------------------------------------------------------------------ 
  select isa_ok(
    (
      select todo_fn_api.create_todo(
        _name => :'_todo_name_2'::citext
        ,_parent_todo_id => (select id from todo.todo where name = :'_todo_list_name'::citext)
      )
    )
    ,'todo.todo'
    ,'should create a todo'
  );
      select isa_ok(
        (select id from todo.todo where name = :'_todo_name_2'::citext)
        ,'uuid'
        ,'todo 1 id should be uuid'
      );
      select is(
        (select status from todo.todo where name = :'_todo_name_2'::citext)::todo.todo_status
        ,'incomplete'::todo.todo_status
        ,'todo status should be incomplete'
      );
  ------------------------------------------------------------------------ 
  select isa_ok(
    (
      select todo_fn_api.update_todo_status(
        _todo_id => (select id from todo.todo where name = :'_todo_name_1'::citext)
        ,_status => 'complete'
      )
    )
    ,'todo.todo'
    ,'should todo 1'
  );
      select is(
        (select status from todo.todo where name = :'_todo_name_1')::todo.todo_status
        ,'complete'::todo.todo_status
        ,'todo status should be complete'
      );
  select isa_ok(
    (
      select todo_fn_api.update_todo_status(
        _todo_id => (select id from todo.todo where name = :'_todo_name_2'::citext)
        ,_status => 'complete'
      )
    )
    ,'todo.todo'
    ,'should complete all todos'
  );
      select is(
        (select status from todo.todo where name = :'_todo_name_2')::todo.todo_status
        ,'complete'::todo.todo_status
        ,'todo status should be complete'
      );
      select is(
        (select status from todo.todo where name = :'_todo_list_name')::todo.todo_status
        ,'complete'::todo.todo_status
        ,'todo list status should be complete'
      );
  ---------------------------------------------------------------------- 
  select is(
    (
      select todo_fn_api.delete_todo(
        _todo_id => (select id from todo.todo where name = :'_todo_name_1')::uuid
      )
    )
    ,true
    ,'should delete a todo'
  );
      select is(
        (select count(*) from todo.todo where name = :'_todo_name_1')::integer
        ,0::integer
        ,'should be no todo with _todo_name_1'
      );
  ---------------------------------------------------------------------- 
  select is(
    (
      select todo_fn_api.delete_todo(
        _todo_id => (select id from todo.todo where name = :'_todo_name_2')::uuid
      )
    )
    ,true
    ,'should delete a todo'
  );
      select is(
        (select count(*) from todo.todo where name = :'_todo_name_2')::integer
        ,0::integer
        ,'should be no todo with _todo_name_2'
      );
  ---------------------------------------------------------------------- 
  select is(
    (select type from todo.todo where name = :'_todo_list_name'::citext)::todo.todo_type
    ,'task'::todo.todo_type
    ,'todo list type should be task'
  );
  select is(
    (
      select todo_fn_api.delete_todo(
        _todo_id => (select id from todo.todo where name = :'_todo_list_name')::uuid
      )
    )
    ,true
    ,'should delete a todo list'
  );
  select is(
    (select count(*) from todo.todo)::integer
    ,0::integer
    ,'should be no todos'
  );
------------------------------------------------------------------------ 
-- END EXERCISE TODO FUNCTIONS
------------------------------------------------------------------------ 

SELECT * FROM finish();
ROLLBACK;
