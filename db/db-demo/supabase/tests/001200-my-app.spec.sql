BEGIN;
-- SELECT plan(7);
SELECT * FROM no_plan();

-- Examples: https://pgtap.org/documentation.html
\set _app_tenant_name 'my-app-test-tenant'
\set _app_tenant_admin_email 'my-app-test-tenant1-admin@example.com'
-- \set _license_pack_key 'my-app'
\set _identifier 'my-app-test-tenant'
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
-- EXERCISE MY APP FUNCTIONS
------------------------------------------------------------------------ 
  \set _data_point_1 "test my app 1"
  \set _data_point_2 "test my app 2"

  select test_helpers.login_as_user(
    _email => :'_app_tenant_admin_email'::citext
  );
  ------------------------------------ test permissions
  select is(
    (select auth_ext.has_permission('p:app'))
    ,true
    ,'_app_tenant_admin_email user should have app permission'
  );
  select is(
    (select auth_ext.has_permission('p:my-app'))
    ,true
    ,'_app_tenant_admin_email user should have my-app permission'
  );
  select is(
    (select auth_ext.has_permission('p:my-app-admin'))
    ,true
    ,'_app_tenant_admin_email user should have p:my-app-admin permission'
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
      select my_app_fn_api.record_data_point(
        _data => :'_data_point_1'::citext
      )
    )
    ,'my_app.my_data_point'
    ,'should create a my_data_point'
  );
------------------------------------------------------------------------ 
-- END EXERCISE MY APP FUNCTIONS
------------------------------------------------------------------------ 

SELECT * FROM finish();
ROLLBACK;
