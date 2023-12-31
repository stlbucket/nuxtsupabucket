create schema if not exists app_fn;
create schema if not exists app_fn_api;

----------------------------------------------------------------------------------------------
create type app_fn.app_user_claims as (
  app_user_id uuid
  ,app_tenant_id uuid
  ,app_user_tenancy_id uuid
  ,actual_app_user_tenancy_id uuid
  ,app_user_status app.app_user_status
  ,permissions citext[]
  ,email citext
  ,display_name citext
  ,app_tenant_name citext
);
----------------------------------------------------------------------------------------------
create type app_fn.license_type_info as (
  key citext
  ,display_name citext
  ,permission_level app.license_type_permission_level
  ,permissions citext[]
);
----------------------------------------------------------------------------------------------
create type app_fn.license_pack_license_type_info as (
  license_type_key citext
  ,number_of_licenses integer
  ,expiration_interval_type app.expiration_interval_type
  ,expiration_interval_multiplier integer
);
----------------------------------------------------------------------------------------------
create type app_fn.license_pack_info as (
  key citext
  ,display_name citext
  ,license_pack_license_type_infos app_fn.license_pack_license_type_info[]
);
----------------------------------------------------------------------------------------------
create type app_fn.application_info as (
  key citext
  ,name citext
  ,license_type_infos app_fn.license_type_info[]
  ,license_pack_infos app_fn.license_pack_info[]
);
----------------------------------------------------------------------------------------------
create type app_fn.ab_listing as (
  app_user_id uuid
  ,email citext
  ,phone citext
  ,full_name citext
  ,display_name citext
  ,can_invite boolean
);
----------------------------------------------------------------------------------------------
