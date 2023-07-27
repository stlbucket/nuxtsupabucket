---------------------------------------------- record_other_data_point
CREATE OR REPLACE FUNCTION my_other_app_fn_api.record_other_data_point(
    _data citext
  )
  RETURNS my_other_app.my_data_point
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval my_other_app.my_data_point;
  BEGIN
    _retval := my_other_app_fn.record_other_data_point(
      _data
      ,auth_ext.app_user_tenancy_id()
      ,auth_ext.app_tenant_id()
    );
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION my_other_app_fn.record_other_data_point(
    _data citext
    ,_app_user_tenancy_id uuid
    ,_app_tenant_id uuid
  )
  RETURNS my_other_app.my_data_point
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval my_other_app.my_data_point;
  BEGIN
    insert into my_other_app.my_data_point(data, app_user_tenancy_id, app_tenant_id) values ( _data, _app_user_tenancy_id, _app_tenant_id)
    returning * into _retval
    ;

    return _retval;
  end;
  $$;

---------------------------------------------- install_my_other_application
CREATE OR REPLACE FUNCTION my_other_app_fn.install_my_other_application()
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
        'my-other-app'::citext
        ,'My Other App'::citext
        ,array[
          row(
            'my-other-app-user'::citext
            ,'My Other App User'::citext
            ,'user'::app.license_type_permission_level
            ,'{"p:my-other-app-user"}'::citext[]
          )::app_fn.license_type_info
          ,row(
            'my-other-app-admin'::citext
            ,'Other App Admin'::citext
            ,'admin'::app.license_type_permission_level
            ,'{"p:my-other-app-admin"}'::citext[]
          )::app_fn.license_type_info
          ,row(
            'my-other-app-admin-trial'::citext
            ,'Other App Trial Admin'::citext
            ,'admin'::app.license_type_permission_level
            ,'{"p:my-other-app-admin"}'::citext[]
          )::app_fn.license_type_info
          ,row(
            'my-other-app-user-trial'::citext
            ,'Other App Trial User'::citext
            ,'user'::app.license_type_permission_level
            ,'{"p:my-other-app-user"}'::citext[]
          )::app_fn.license_type_info
        ]::app_fn.license_type_info[]
        ,array[
          row(
            'my-other-app'::citext
            ,'My Other App'::citext
            ,array[
              row(
                'my-other-app-user'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
              ,row(
                'my-other-app-admin'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
            ]::app_fn.license_pack_license_type_info[]
          )::app_fn.license_pack_info
          ,row(
            'my-other-app-trial'::citext
            ,'My Other App Trial'::citext
            ,array[
              row(
                'my-other-app-admin-trial'::citext
                ,0::integer
                ,'week'::app.expiration_interval_type
                ,6::integer
              )::app_fn.license_pack_license_type_info
              ,row(
                'my-other-app-user-trial'::citext
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
