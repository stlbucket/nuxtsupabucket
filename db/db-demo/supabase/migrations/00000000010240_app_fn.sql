----------------------------------------------------------------- configure_user_metadata
CREATE OR REPLACE FUNCTION app_fn.configure_user_metadata(_app_user_id uuid, _actual_app_user_tenancy uuid default null)
  RETURNS void
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _app_user_claims app_fn.app_user_claims;
  BEGIN
    _app_user_claims := app_fn.current_app_user_claims(_app_user_id);
    _app_user_claims.actual_app_user_tenancy_id = _actual_app_user_tenancy;

    update auth.users set 
      raw_user_meta_data = (select to_jsonb(_app_user_claims))
    where id = _app_user_id
    ;
  end;
  $$;  
----------------------------------- handle_new_user
create or replace function app_fn.handle_new_user()
  returns trigger
  language plpgsql
  security definer --set search_path = public
  as $$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  begin
    insert into app.app_user (id, email, display_name)
    values (new.id, new.email, split_part(new.email, '@', 1));

    update app.app_user_tenancy set
      app_user_id = new.id
      ,status = 'active'
    where email = new.email
    ;

    select * into _app_user_tenancy from app.app_user_tenancy where app_user_id = new.id and status = 'active' limit 1;

    update auth.users set 
      raw_user_meta_data = (select to_jsonb(app_fn.current_app_user_claims(_app_user_tenancy.app_user_id)))
    where id = _app_user_tenancy.app_user_id
    ;

    return new;
  end;
  $$;
-- trigger the function every time a user is created
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure app_fn.handle_new_user();

----------------------------------- install_application
CREATE OR REPLACE FUNCTION app_fn.install_application(_application_info app_fn.application_info)
  RETURNS app.application
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _application app.application;
    _license_pack app.license_pack;
    _license_type_info app_fn.license_type_info;
    _license_pack_license_type_info app_fn.license_pack_license_type_info;
    _license_pack_info app_fn.license_pack_info;
    _permission_key citext;
  BEGIN
    insert into app.application(
        key
        ,name
      ) values (
        _application_info.key::citext
        ,_application_info.name::citext
      )
      on conflict(key)
      do update set
        name = _application_info.name
      returning *
      into _application
      ;

    
    foreach _license_type_info in array(_application_info.license_type_infos)
    loop
      insert into app.license_type(
          application_key
          ,key
          ,display_name
          ,permission_level
        )
        values (
          _application_info.key
          ,_license_type_info.key
          ,_license_type_info.display_name
          ,_license_type_info.permission_level
        )
        on conflict(key)
        do nothing
        ;

      foreach _permission_key in array(_license_type_info.permissions)
      loop
        insert into app.permission(key)
          values (_permission_key)
          on conflict(key)
          do nothing
          ;

        insert into app.license_type_permission(license_type_key, permission_key)
          values
            (_license_type_info.key, _permission_key)
          on conflict(license_type_key, permission_key)
          do nothing
          ;
      end loop;
    end loop;

    foreach _license_pack_info in array(_application_info.license_pack_infos)
    loop
      insert into app.license_pack(key, display_name)
        values 
          (_license_pack_info.key, _license_pack_info.display_name)
        on conflict(key)
        do update set display_name = _license_pack_info.display_name
        returning * into _license_pack
        ;

      foreach _license_pack_license_type_info in array(_license_pack_info.license_pack_license_type_infos)
      loop
        insert into app.license_pack_license_type(
            license_pack_key
            ,license_type_key
            ,number_of_licenses
            ,expiration_interval_type
            ,expiration_interval_multiplier
          )
          values
            (
              _license_pack.key
              ,_license_pack_license_type_info.license_type_key
              ,_license_pack_license_type_info.number_of_licenses
              ,_license_pack_license_type_info.expiration_interval_type
              ,_license_pack_license_type_info.expiration_interval_multiplier

            )
          on conflict(license_pack_key, license_type_key)
          do nothing
          ;
      end loop;
    
    end loop;

    return _application;
  end;
  $function$
  ;

----------------------------------- install_anchor_application
CREATE OR REPLACE FUNCTION app_fn.install_anchor_application()
  RETURNS app.application
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _application app.application;
  BEGIN
    _application := app_fn.install_application(
      _application_info => row(
        'app'::citext
        ,'App'::citext
        ,array[
          row(
            'app-user'::citext
            ,'App User'::citext
            ,'user'::app.license_type_permission_level
            ,'{"p:app-user"}'::citext[]
          )::app_fn.license_type_info
          ,row(
            'app-admin'::citext
            ,'App Admin'::citext
            ,'admin'::app.license_type_permission_level
            ,'{"p:app-admin"}'::citext[]
          )::app_fn.license_type_info
          ,row(
            'app-admin-super'::citext
            ,'App Super Admin'::citext
            ,'superadmin'::app.license_type_permission_level
            ,'{"p:app-admin-super","p:app-admin-support"}'::citext[]
          )::app_fn.license_type_info
          ,row(
            'app-admin-support'::citext
            ,'App Support Admin'::citext
            ,'admin'::app.license_type_permission_level
            ,'{"p:app-admin-support"}'::citext[]
          )::app_fn.license_type_info
          ,row(
            'app-admin-trial'::citext
            ,'App Trial Admin'::citext
            ,'admin'::app.license_type_permission_level
            ,'{"p:app-admin"}'::citext[]
          )::app_fn.license_type_info
          ,row(
            'app-user-trial'::citext
            ,'App Trial User'::citext
            ,'user'::app.license_type_permission_level
            ,'{"p:app-user"}'::citext[]
          )::app_fn.license_type_info
        ]::app_fn.license_type_info[]
        ,array[
          row(
            'anchor'::citext
            ,'Anchor'::citext
            ,array[
              row(
                'app-admin-super'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
              ,row(
                'app-admin-support'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
            ]::app_fn.license_pack_license_type_info[]
          )::app_fn.license_pack_info
          ,row(
            'app'::citext
            ,'App'::citext
            ,array[
              row(
                'app-user'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
              ,row(
                'app-admin'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
            ]::app_fn.license_pack_license_type_info[]
          )::app_fn.license_pack_info
          ,row(
            'app-trial'::citext
            ,'App Trial'::citext
            ,array[
              row(
                'app-admin-trial'::citext
                ,0::integer
                ,'week'::app.expiration_interval_type
                ,6::integer
              )::app_fn.license_pack_license_type_info
              ,row(
                'app-user-trial'::citext
                ,0::integer
                ,'week'::app.expiration_interval_type
                ,6::integer
              )::app_fn.license_pack_license_type_info
            ]::app_fn.license_pack_license_type_info[]
          )::app_fn.license_pack_info
        ]::app_fn.license_pack_info[]

      )::app_fn.application_info
    );

    return _application;
  end;
  $function$
  ;

----------------------------------- create_anchor_tenant
CREATE OR REPLACE FUNCTION app_fn.create_anchor_tenant(_name citext, _email citext default null)
  RETURNS app.app_tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _application app.application;
    _app_tenant app.app_tenant;
  BEGIN
    select * into _app_tenant from app.app_tenant where type = 'anchor';
    if _app_tenant.id is null then
      _application := (select app_fn.install_anchor_application());
    --   -- create the app tenant
      insert into app.app_tenant(
        name
        ,identifier
        ,type
      ) values (
        _name
        ,'anchor'
        ,'anchor'
      ) returning * into _app_tenant
      ;

      perform app_fn.subscribe_tenant_to_license_pack(_app_tenant.id, 'anchor');
      perform app_fn.subscribe_tenant_to_license_pack(_app_tenant.id, 'app');
      perform app_fn.invite_user(_app_tenant.id, _email, 'superadmin');
    end if;
    
    return _app_tenant;
  end;
  $function$
  ;

----------------------------------- current_app_user_claims
CREATE OR REPLACE FUNCTION app_fn_api.current_app_user_claims()
  RETURNS app_fn.app_user_claims
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user_claims app_fn.app_user_claims;
  BEGIN
    _app_user_claims = (select app_fn.current_app_user_claims(auth.uid()));
    return _app_user_claims;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.current_app_user_claims(_app_user_id uuid)
  RETURNS app_fn.app_user_claims
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user app.app_user;
    _app_user_tenancy app.app_user_tenancy;
    _app_user_claims app_fn.app_user_claims;
  BEGIN
    select * into _app_user from app.app_user where id = _app_user_id;
    select * into _app_user_tenancy from app.app_user_tenancy where app_user_id = _app_user_id and status = 'active';

    _app_user_claims.email = _app_user.email;
    _app_user_claims.app_user_status = (select status from app.app_user where id = _app_user_id);
    if _app_user_tenancy.id is not null then
      _app_user_claims.display_name = _app_user_tenancy.display_name;
      _app_user_claims.app_user_id = _app_user_tenancy.app_user_id;
      _app_user_claims.app_tenant_id = _app_user_tenancy.app_tenant_id;
      _app_user_claims.app_tenant_name = _app_user_tenancy.app_tenant_name;
      _app_user_claims.app_user_tenancy_id = _app_user_tenancy.id;
      _app_user_claims.permissions = (
        select array_agg(ltp.permission_key) 
        from app.license_type_permission ltp 
        join app.license_type lt on lt.key = ltp.license_type_key
        join app.license l on l.license_type_key = lt.key
        where l.app_user_tenancy_id = _app_user_tenancy.id
      );
    else
      _app_user_claims.app_user_id = _app_user_id;
    end if;

    
    return _app_user_claims;
  end;
  $function$
  ;

----------------------------------- decline_invitation
CREATE OR REPLACE FUNCTION app_fn_api.decline_invitation(_app_user_tenancy_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    _app_user_tenancy := app_fn.decline_invitation(_app_user_tenancy_id);
    return _app_user_tenancy;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.decline_invitation(_app_user_tenancy_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    update app.app_user_tenancy set 
      status = 'declined'
      ,updated_at = current_timestamp 
    where id = _app_user_tenancy_id 
    returning * 
    into _app_user_tenancy;

    return _app_user_tenancy;
  end;
  $function$
  ;

----------------------------------- update_profile
CREATE OR REPLACE FUNCTION app_fn_api.update_profile(
    _display_name citext
    ,_first_name citext
    ,_last_name citext
    ,_phone citext default null
  )
  RETURNS app.app_user
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user app.app_user;
  BEGIN
    _app_user := app_fn.update_profile(
      auth.uid()
      ,_display_name
      ,_first_name
      ,_last_name
      ,_phone
    );
    return _app_user;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.update_profile(
    _app_user_id uuid
    ,_display_name citext
    ,_first_name citext
    ,_last_name citext
    ,_phone citext default null
  )
  RETURNS app.app_user
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $function$
  DECLARE
    _app_user app.app_user;
  BEGIN
    update app.app_user_tenancy set 
      display_name = _display_name
      ,updated_at = current_timestamp 
    where app_user_id = _app_user_id
    ;

    update app.app_user set 
      display_name = _display_name
      ,first_name = _first_name
      ,last_name = _last_name
      ,phone = _phone
      ,updated_at = current_timestamp 
    where id = _app_user_id
    returning * 
    into _app_user;

    perform app_fn.configure_user_metadata(_app_user.id);
    -- update auth.users set 
    --   raw_user_meta_data = (select to_jsonb(app_fn.current_app_user_claims(_app_user.id)))
    -- where id = _app_user.id
    -- ;

    return _app_user;
  end;
  $function$
  ;

----------------------------------- assume_app_user_tenancy
CREATE OR REPLACE FUNCTION app_fn_api.assume_app_user_tenancy(_app_user_tenancy_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    _app_user_tenancy := app_fn.assume_app_user_tenancy(_app_user_tenancy_id, auth_ext.email());
    return _app_user_tenancy;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.assume_app_user_tenancy(_app_user_tenancy_id uuid, _email citext)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $function$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    select * into _app_user_tenancy from app.app_user_tenancy where id = _app_user_tenancy_id and email = _email;
    -- raise exception '%', _app_user_tenancy;

    if _app_user_tenancy.id is not null then
      update app.app_user_tenancy set 
        status = 'inactive' 
        ,updated_at = current_timestamp 
      where app_user_id = _app_user_tenancy.app_user_id
      and status in ('active', 'supporting')
      and id != _app_user_tenancy_id 
      ;

      update app.app_user_tenancy set 
        status = 'active' 
        ,updated_at = current_timestamp 
      where id = _app_user_tenancy_id
      returning * 
      into _app_user_tenancy;

      -- perform app_fn.configure_user_metadata(_app_user_tenancy.app_user_id);
      update auth.users set 
        raw_user_meta_data = (select to_jsonb(app_fn.current_app_user_claims(_app_user_tenancy.app_user_id)))
      where id = _app_user_tenancy.app_user_id
      ;
    end if;

    return _app_user_tenancy;
  end;
  $function$
  ;

----------------------------------- create_app_tenant
CREATE OR REPLACE FUNCTION app_fn_api.create_app_tenant(_name citext, _identifier citext default null, _email citext default null, _type app.app_tenant_type default 'customer'::app.app_tenant_type)
  RETURNS app.app_tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant app.app_tenant;
  BEGIN
    _app_tenant := app_fn.create_app_tenant(_name, _identifier, _email, _type);
    return _app_tenant;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.create_app_tenant(_name citext, _identifier citext default null, _email citext default null, _type app.app_tenant_type default 'customer'::app.app_tenant_type)
  RETURNS app.app_tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant app.app_tenant;
  BEGIN
    -- check for an existing tenant by this name
    select * into _app_tenant from app.app_tenant where name = _name or (_identifier is not null and identifier = _identifier);
    if _app_tenant.id is not null then
      raise exception '30002: APP TENANT WITH THIS NAME OR IDENTIFIER ALREADY EXISTS';
    end if;

    -- create the app tenant
    insert into app.app_tenant(
      name
      ,identifier
      ,type
    ) values (
      _name
      ,_identifier
      ,_type
    ) returning * into _app_tenant
    ;

    perform app_fn.subscribe_tenant_to_license_pack(_app_tenant.id, 'app');
    perform app_fn.subscribe_tenant_to_license_pack(_app_tenant.id, 'my-app');
    perform app_fn.invite_user(_app_tenant.id, _email, 'admin');

    return _app_tenant;
  end;
  $function$
  ;

----------------------------------- invite_user
CREATE OR REPLACE FUNCTION app_fn_api.invite_user(_email citext)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user app.app_user;
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    -- this function invites a user to the same tenant as the current user
    -- can only be called by user with app-admin license or better.

    if auth_ext.has_permission('p:app-admin') = false then
      raise exception '30000: UNAUTHORIZED';
    end if;

    select * into _app_user_tenancy 
    from app.app_user_tenancy 
    where app_user_id = auth.uid() 
    and status = 'active'
    ;

    _app_user_tenancy = (select app_fn.invite_user(_app_user_tenancy.app_tenant_id, _email));

    return _app_user_tenancy;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.invite_user(
    _app_tenant_id uuid
    ,_email citext
    ,_permission_level app.license_type_permission_level default 'user'
  )
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
          -- security definer to allow for select of app.app_user from other tenants
          -- this would allow for one tenant to know if a user at an email were on
          -- the platform - though the other would know that they know.  so it would
          -- all be known knowns and no unknown unknowns.  -- donny r
  AS $function$
  DECLARE
    _app_user app.app_user;
    _app_user_tenancy app.app_user_tenancy;
    _app_tenant app.app_tenant;
    _license_pack_license_type app.license_pack_license_type;
    _license_type_key citext;
    _app_tenant_subscription_id uuid;
  BEGIN    
    -- find existing records for app_user and tenancy
    select * into _app_user from app.app_user where email = _email;
    select * into _app_user_tenancy from app.app_user_tenancy where email = _email and app_tenant_id = _app_tenant_id;
    select * into _app_tenant from app.app_tenant where id = _app_tenant_id;

    if _app_user_tenancy.id is null then
      insert into app.app_user_tenancy(
        app_tenant_id
        ,app_tenant_name
        ,email
        ,display_name
      ) values (
        _app_tenant.id
        ,_app_tenant.name
        ,_email
        ,coalesce(_app_user.display_name, split_part(_email,'@',1))
      ) 
      returning * into _app_user_tenancy;

      for _license_type_key, _app_tenant_subscription_id in
        select lplt.license_type_key, ats.id
          from app.license_pack_license_type lplt
          join app.license_type lt on lt.key = lplt.license_type_key
          join app.license_pack lp on lp.key = lplt.license_pack_key
          join app.app_tenant_subscription ats on ats.license_pack_key = lp.key
          where ats.app_tenant_id = _app_tenant_id
          and lt.permission_level = _permission_level
      loop

        insert into app.license(
          app_tenant_id
          ,app_user_tenancy_id
          ,app_tenant_subscription_id
          ,license_type_key
        )
        values (
          _app_tenant_id
          ,_app_user_tenancy.id
          ,_app_tenant_subscription_id
          ,_license_type_key
        )
        on conflict (app_user_tenancy_id, license_type_key) DO UPDATE SET updated_at = EXCLUDED.updated_at
        ;
      end loop;
    end if;
    
    -- attach tenancy to any existing user
    if _app_user.id is not null then
      update app.app_user_tenancy set app_user_id = _app_user.id where id = _app_user_tenancy.id returning * into _app_user_tenancy;
    end if;

    return _app_user_tenancy;
  end;
  $function$
  ;

----------------------------------- subscribe_tenant_to_license_pack
CREATE OR REPLACE FUNCTION app_fn_api.subscribe_tenant_to_license_pack(_app_tenant_id uuid, _license_pack_key citext)
  RETURNS app.app_tenant_subscription
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant_subcription app.app_tenant_subscription;
  BEGIN
    _app_tenant_subcription := app_fn.subscribe_tenant_to_license_pack(_app_tenant_id, _license_pack_key);
    return _app_tenant_subcription;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.subscribe_tenant_to_license_pack(_app_tenant_id uuid, _license_pack_key citext)
  RETURNS app.app_tenant_subscription
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant_subcription app.app_tenant_subscription;
    _app_user app.app_user;
    _app_user_tenancy app.app_user_tenancy;
    _license_pack_license_type app.license_pack_license_type;
    _license_type_key citext;
  BEGIN
    insert into app.app_tenant_subscription(
      app_tenant_id
      ,license_pack_key
    ) values (
      _app_tenant_id
      ,_license_pack_key
    )
    returning * into _app_tenant_subcription
    ;

    for _license_type_key in
      select lplt.license_type_key
        from app.license_pack_license_type lplt
        join app.license_type lt on lt.key = lplt.license_type_key
        where lplt.license_pack_key = _license_pack_key
        and lt.permission_level = 'admin'
    loop
      insert into app.license(
        app_tenant_id
        ,app_user_tenancy_id
        ,app_tenant_subscription_id
        ,license_type_key
      )
      select
        _app_tenant_id
        ,aut.id
        ,_app_tenant_subcription.id
        ,_license_type_key
      from app.app_user_tenancy aut
      join app.license l on l.app_user_tenancy_id = aut.id
      where l.license_type_key = 'app-admin'
      and l.app_tenant_id = _app_tenant_id
      on conflict (app_user_tenancy_id, license_type_key) DO UPDATE SET updated_at = EXCLUDED.updated_at
      ;
    end loop;
      
    return _app_tenant_subcription;
  end;
  $function$
  ;

---------------------------------------------------------------------- queries

----------------------------------- my_app_user_tenancies
CREATE OR REPLACE FUNCTION app_fn_api.my_app_user_tenancies()
  RETURNS setof app.app_user_tenancy
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    
  BEGIN
    return query select * from app_fn.my_app_user_tenancies(auth_ext.email());
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.my_app_user_tenancies(_email text)
  RETURNS setof app.app_user_tenancy
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    
  BEGIN
    return query
    select aut.*
    from app.app_user_tenancy aut
    where email = _email
    ;
  end;
  $function$
  ;

----------------------------------- app_tenant_app_user_tenancies
CREATE OR REPLACE FUNCTION app_fn_api.app_tenant_app_user_tenancies()
  RETURNS setof app.app_user_tenancy
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    
  BEGIN
    -- raise exception 'blah %', auth_ext.app_tenant_id();
    return query select * from app_fn.app_tenant_app_user_tenancies(auth_ext.app_tenant_id());
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.app_tenant_app_user_tenancies(_app_tenant_id uuid)
  RETURNS setof app.app_user_tenancy
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    
  BEGIN
    return query
    select aut.*
    from app.app_user_tenancy aut
    join app.license l on l.app_user_tenancy_id = aut.id
    where aut.app_tenant_id = _app_tenant_id
    and l.license_Type_key != 'app-admin-support'
    ;
  end;
  $function$
  ;

----------------------------------- app_tenant_licenses
CREATE OR REPLACE FUNCTION app_fn_api.app_tenant_licenses()
  RETURNS setof app.license
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    
  BEGIN
    return query select * from app_fn.app_tenant_licenses(auth_ext.app_tenant_id());
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.app_tenant_licenses(_app_tenant_id uuid)
  RETURNS setof app.license
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    
  BEGIN
    return query
    select l.*
    from app.license l
    where l.license_Type_key != 'app-admin-support'
    ;
  end;
  $function$
  ;

----------------------------------- demo_app_user_tenancies
CREATE OR REPLACE FUNCTION app_fn_api.demo_app_user_tenancies()
  RETURNS setof app.app_user_tenancy
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
  BEGIN
    return query select * from app_fn.demo_app_user_tenancies();
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.demo_app_user_tenancies()
  RETURNS setof app.app_user_tenancy
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  AS $function$
  DECLARE
  BEGIN
    return query
    select distinct
      aut.*
    from app.app_user_tenancy aut
    join app.app_tenant t on t.id = aut.app_tenant_id
    where (t.type = 'demo' or t.type = 'anchor')
    and aut.display_name != 'Site Support'
    ;
  end;
  $function$
  ;
----------------------------------------------------------------- join_address_book
CREATE OR REPLACE FUNCTION app_fn_api.join_address_book()
  RETURNS app.app_user
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _app_user app.app_user;
  BEGIN
    _app_user := app_fn.join_address_book(auth.uid());
    return _app_user;
  end;
  $$;  

CREATE OR REPLACE FUNCTION app_fn.join_address_book(_app_user_id uuid)
  RETURNS app.app_user
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _app_user app.app_user;
  BEGIN
    raise notice '_app_user_id: %', _app_user_id;
    raise notice 'email: %', (select email from app.app_user where id = _app_user_id);
    
    update app.app_user set
      is_public = true
    where id = _app_user_id
    returning *
    into _app_user
    ;

    raise notice '_app_user: %', _app_user;

    return _app_user;
  end;
  $$;  
----------------------------------------------------------------- leave_address_book
CREATE OR REPLACE FUNCTION app_fn_api.leave_address_book()
  RETURNS app.app_user
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _app_user app.app_user;
  BEGIN
    _app_user := app_fn.leave_address_book(auth.uid());
    return _app_user;
  end;
  $$;  

CREATE OR REPLACE FUNCTION app_fn.leave_address_book(_app_user_id uuid)
  RETURNS app.app_user
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _app_user app.app_user;
  BEGIN
    update app.app_user set
      is_public = false
    where id = _app_user_id
    returning *
    into _app_user
    ;

    return _app_user;
  end;
  $$;  
----------------------------------------------------------------- get_ab_listings
CREATE OR REPLACE FUNCTION app_fn_api.get_ab_listings(_app_user_id uuid)
  RETURNS SETOF app_fn.ab_listing
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $$
  DECLARE
  BEGIN
    return query select * from app_fn.get_ab_listings(auth.uid(), auth_ext.app_tenant_id());
  end;
  $$;  
----------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION app_fn.get_ab_listings(_app_user_id uuid, _user_app_tenant_id uuid)
  RETURNS SETOF app_fn.ab_listing
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  AS $$
  DECLARE
    _can_invite boolean;
  BEGIN
    _can_invite := auth_ext.has_permission('p:app-admin');

    return query
      select 
        u.id as app_user_id
        ,u.email
        ,u.phone
        ,u.full_name
        ,u.display_name
        ,(
          select _can_invite 
          and (u.id != _app_user_id)
          and not exists (select id from app.app_user_tenancy where app_tenant_id = _user_app_tenant_id and app_user_id = u.id)
        ) as _can_invite
      from app.app_user u
      where is_public = true
      and exists(select id from app.app_user where id = _app_user_id and is_public = true)
      ;
  end;
  $$;  
----------------------------------------------------------------- get_ab_listings
CREATE OR REPLACE FUNCTION app_fn_api.get_myself()
  RETURNS app.app_user
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  AS $$
  DECLARE
    _app_user app.app_user;
  BEGIN
    select * into _app_user from app.app_user where id = auth.uid();
    return _app_user;
  end;
  $$;  
----------------------------------------------------------------- become_support
CREATE OR REPLACE FUNCTION app_fn_api.become_support(_app_tenant_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    if auth_ext.has_permission('p:app-admin-support') = false then
      raise exception '30000: PERMISSION DENIED';
    end if;

    _app_user_tenancy := (select app_fn.become_support(_app_tenant_id, auth.uid()));
    return _app_user_tenancy;
  end;
  $$;  

CREATE OR REPLACE FUNCTION app_fn.become_support(_app_tenant_id uuid, _app_user_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _app_tenant app.app_tenant;
    _app_user_tenancy app.app_user_tenancy;
    _actual_app_user_tenancy app.app_user_tenancy;
  BEGIN
      select * into _app_tenant from app.app_tenant where id = _app_tenant_id;

      update app.app_user_tenancy set status = 'supporting' 
      where app_user_id = _app_user_id and status = 'active'
      returning * into _actual_app_user_tenancy;

      insert into app.app_user_tenancy(
        app_tenant_id
        ,app_user_id
        ,app_tenant_name
        ,email
        ,display_name
        ,status
      ) values (
        _app_tenant.id
        ,_app_user_id
        ,_app_tenant.name
        ,'support@example.com'
        ,'Site Support'
        ,'active'
      )
      on conflict(app_tenant_id, app_user_id) do update
        set status = 'active'
      returning * into _app_user_tenancy
      ;

      insert into app.license(
        app_tenant_id
        ,app_user_tenancy_id
        ,app_tenant_subscription_id
        ,license_type_key
      )
      values (
        _app_user_tenancy.app_tenant_id
        ,_app_user_tenancy.id
        ,(select id from app.app_tenant_subscription where app_tenant_id = _app_user_tenancy.app_tenant_id limit 1)
        ,'app-admin-support'
      )
      on conflict (app_user_tenancy_id, license_type_key) DO NOTHING
      -- on conflict (app_user_tenancy_id, license_type_key) DO UPDATE SET updated_at = current_timestamp
      ;

      insert into app.license(
        app_tenant_id
        ,app_user_tenancy_id
        ,app_tenant_subscription_id
        ,license_type_key
      )
      select
        _app_user_tenancy.app_tenant_id
        ,_app_user_tenancy.id
        ,ats.id
        ,lplt.license_type_key
      from app.app_tenant_subscription ats
      join app.license_pack lp on lp.key = ats.license_pack_key
      join app.license_pack_license_type lplt on lplt.license_pack_key = lp.key
      join app.license_type lt on lt.key = lplt.license_Type_key
      where ats.app_tenant_id = _app_user_tenancy.app_tenant_id
      and lt.permission_level = 'admin'
      and not exists (
        select id from app.license
        where app_user_tenancy_id = _app_user_tenancy.id
        and license_type_key = lplt.license_Type_key
      )
      on conflict (app_user_tenancy_id, license_type_key) DO NOTHING
      -- on conflict (app_user_tenancy_id, license_type_key) DO UPDATE SET updated_at = current_timestamp
      ;

      perform app_fn.configure_user_metadata(_app_user_tenancy.app_user_id, _actual_app_user_tenancy.id);
      -- update auth.users set 
      --   raw_user_meta_data = (select to_jsonb(app_fn.current_app_user_claims(_app_user_tenancy.app_user_id)))
      -- where id = _app_user_tenancy.app_user_id
      -- ;

    return _app_user_tenancy;
  end;
  $$;  
----------------------------------- grant_user_license
  -- CREATE OR REPLACE FUNCTION app_fn.grant_user_license(_license_type_key citext, _app_user_id uuid)
  --   RETURNS app.license
  --   LANGUAGE plpgsql
  --   VOLATILE
  --   SECURITY INVOKER
  --   AS $function$
  --   DECLARE
  --     _app_tenant_subcription app.app_tenant_subscription;
  --     _app_user app.app_user;
  --     _app_user_tenancy app.app_user_tenancy;
  --     _license_pack_license_type app.license_pack_license_type;
  --     _license_type_key citext;
  --     _app_tenant_id uuid;
  --   BEGIN
  --     _app_tenant_id = ((auth.jwt()->'user_metadata')->'app_tenant_id')::uuid;

  --     _app_tenant_subcription := (
  --       select ats.* 
  --       from app.app_tenant_subscription ats
  --       join app.license_pack lp on lp.key = ats.license_pack_key
  --       join app.license_pack_license_type lplt on lplt.license_pack_key = lp.key
  --       where lplt.license_type_key = _license_type_key
  --       and ats.app_tenant_id = _app_tenant_id
  --     );

  --     if _app_tenant_subcription.id is null then
  --       raise exception '30006: NO SUBSCRIPTION CONTAINS LICENSE TYPE KEY';
  --     end if;

  --     insert into app.license(
  --       app_tenant_id
  --       ,app_tenant_subscription_id
  --       ,app_user_id
  --       ,license_type_key
  --     )

  --     return _app_tenant_subcription;
  --   end;
  --   $function$
  --   ;
