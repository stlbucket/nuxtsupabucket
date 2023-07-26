----------------------------------------------------------------------------------------------
-- this schema provides helpers, primarily to access jwt->user_metadata->A-VALUE
----------------------------------------------------------------------------------------------
create schema if not exists auth_ext;
----------------------------------- auth_ext
CREATE OR REPLACE FUNCTION auth_ext.has_permission(_permission_key citext, _app_tenant_id uuid default null)
  RETURNS boolean
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _retval boolean;
    _permissions citext[];
  BEGIN
    -- raise exception 'jwt: %, %', auth.uid(), auth.jwt();
    -- raise exception 'jwt: %, %', auth.uid(), array(select jsonb_array_elements_text(((auth.jwt()->'user_metadata')->'permissions')));
    _permissions := auth_ext.permissions();
    _retval := (
      SELECT 
      EXISTS (    
        SELECT 1 FROM unnest(_permissions) AS perm  
        WHERE perm LIKE _permission_key||'%'
      ) 
    );
    if _app_tenant_id is not null then
      -- _retval := (select _retval and ((auth.jwt()->'user_metadata')->>'app_tenant_id')::uuid = _app_tenant_id);
      _retval := (select _retval and auth_ext.app_tenant_id() = _app_tenant_id);
    end if;
    return _retval;
  end;
  $function$
  ;
----------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION auth_ext.permissions()
  RETURNS citext[]
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _permissions citext[];
  BEGIN
    _permissions := array(select jsonb_array_elements_text(((auth.jwt()->'user_metadata')->'permissions')))::citext[];
    return _permissions;
  end;
  $function$
  ;
----------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION auth_ext.app_tenant_id()
  RETURNS uuid
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant_id uuid;
  BEGIN
    _app_tenant_id := ((auth.jwt()->'user_metadata')->>'app_tenant_id')::uuid;
    return _app_tenant_id;
  end;
  $function$
  ;
----------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION auth_ext.app_user_tenancy_id()
  RETURNS uuid
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user_tenancy_id uuid;
  BEGIN
    _app_user_tenancy_id := ((auth.jwt()->'user_metadata')->>'app_user_tenancy_id')::uuid;
    return _app_user_tenancy_id;
  end;
  $function$
  ;
----------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION auth_ext.email()
  RETURNS citext
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _email citext;
  BEGIN
    _email := (auth.jwt()->>'email')::citext;
    return _email;
  end;
  $function$
  ;
