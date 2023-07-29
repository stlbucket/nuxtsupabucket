-----------------------------------------------
-- script  todo_fn schema
-----------------------------------------------

create schema if not exists todo_fn_api;
create schema if not exists todo_fn;

-- ----------------------------------------------------------------------------------------------
-- CREATE OR REPLACE FUNCTION todo_fn.install_todo_application()
--   RETURNS app.application
--   LANGUAGE plpgsql
--   VOLATILE
--   SECURITY INVOKER
--   AS $function$
--   DECLARE
--     _application app.application;
--   begin
--     _application := app_fn.install_application(
--       _application_info => row(
--         'todo'::citext
--         ,'Todo'::citext
--         ,array[
--           row(
--             'todo-user'::citext
--             ,'Todo User'::citext
--             ,'user'::app.license_type_permission_level
--             ,'{"p:todo-user"}'::citext[]
--           )::app_fn.license_type_info
--           ,row(
--             'todo-admin'::citext
--             ,'Todo Admin'::citext
--             ,'admin'::app.license_type_permission_level
--             ,'{"p:todo-admin"}'::citext[]
--           )::app_fn.license_type_info
--         ]::app_fn.license_type_info[]
--         ,array[
--           row(
--             'todo'::citext
--             ,'Todo'::citext
--             ,array[
--               row(
--                 'todo-user'::citext
--                 ,0::integer
--                 ,'none'::app.expiration_interval_type
--                 ,0::integer
--               )::app_fn.license_pack_license_type_info
--               ,row(
--                 'todo-admin'::citext
--                 ,0::integer
--                 ,'none'::app.expiration_interval_type
--                 ,0::integer
--               )::app_fn.license_pack_license_type_info
--             ]::app_fn.license_pack_license_type_info[]
--           )::app_fn.license_pack_info
--         ]::app_fn.license_pack_info[]
--       )::app_fn.application_info
--     );
--     return _application;
--   end;
--   $function$
--   ;
-- ------------------------------------------------------


-------------------------------------------------------------------------------- todo-functions
---------------------------------------------- create_todo
CREATE OR REPLACE FUNCTION todo_fn_api.create_todo(
    _name citext
    ,_description citext default null
    ,_parent_todo_id uuid default null
  )
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval todo.todo;
  BEGIN
    _retval := todo_fn.create_todo(
      auth_ext.app_tenant_id()
      ,auth_ext.app_user_tenancy_id()
      ,_name
      ,_description
      ,_parent_todo_id
    );
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.create_todo(
    _app_tenant_id uuid
    ,_app_user_tenancy_id uuid
    ,_name citext
    ,_description citext default null
    ,_parent_todo_id uuid default null
  )
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _ordinal integer;
    _retval todo.todo;
  BEGIN
    _ordinal := 0;
    if _parent_todo_id is not null then
      _ordinal := (select count(*) + 1 from todo.todo where parent_todo_id = _parent_todo_id);
    end if;

    insert into todo.todo(
      app_tenant_id
      ,app_user_tenancy_id
      ,name
      ,description
      ,parent_todo_id
      ,ordinal
    ) 
    values(
      _app_tenant_id
      ,_app_user_tenancy_id
      ,_name
      ,_description
      ,_parent_todo_id
      ,_ordinal
    )
    returning * into _retval;

    if _parent_todo_id is not null then
      if (select parent_todo_id from todo.todo where id = _parent_todo_id) is null then
        update todo.todo set type = 'project' where id = _parent_todo_id;
      else
        update todo.todo set type = 'milestone' where id = _parent_todo_id;
      end if; 

      perform todo_fn.update_todo_status(
        _todo_id => _retval.id
        ,_status => 'incomplete'
      );
    end if;

    
    return _retval;
  end;
  $$;

---------------------------------------------- create_todo
CREATE OR REPLACE FUNCTION todo_fn_api.update_todo(
    _todo_id uuid
    ,_name citext
    ,_description citext default null
  )
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval todo.todo;
  BEGIN
    _retval := todo_fn.update_todo(
      _todo_id
      ,_name
      ,_description
    );
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.update_todo(
    _todo_id uuid
    ,_name citext
    ,_description citext default null
  )
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval todo.todo;
  BEGIN
    update todo.todo set
      name = _name
      ,description = _description
    where id = _todo_id
    returning * into _retval
    ;

    return _retval;
  end;
  $$;

---------------------------------------------- update_todo_status
CREATE OR REPLACE FUNCTION todo_fn_api.update_todo_status(
    _todo_id uuid
    ,_status todo.todo_status
  )
  RETURNS todo.todo
  VOLATILE
  SECURITY INVOKER
  LANGUAGE plpgsql
  AS $function$
  DECLARE
    _todo todo.todo;
  BEGIN
    _todo := todo_fn.update_todo_status(_todo_id, _status);
    return _todo;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION todo_fn.update_todo_status(
    _todo_id uuid
    ,_status todo.todo_status
  )
  RETURNS todo.todo
  VOLATILE
  SECURITY INVOKER
  LANGUAGE plpgsql
  AS $function$
  DECLARE
    _todo todo.todo;
  BEGIN
      update todo.todo set 
        status = _status
        ,updated_at = current_timestamp
      where id = _todo_id
      returning * into _todo
      ;

      if _todo.parent_todo_id is not null then
        if _status = 'complete' then
          if (select count(*) from todo.todo where parent_todo_id = _todo.parent_todo_id and status = 'incomplete') = 0 then
            -- update todo.todo set status = 'complete' where id = _todo.parent_todo_id;
            perform todo_fn.update_todo_status(_todo.parent_todo_id, 'complete');
          end if; 
        end if;

        if _status = 'incomplete' then
          perform todo_fn.update_todo_status(_todo.parent_todo_id, 'incomplete');
          -- update todo.todo set status = 'incomplete' where id = _todo.parent_todo_id;
        end if;
      end if;
      
    return _todo;
  end;
  $function$
  ;

---------------------------------------------- delete_todo
CREATE OR REPLACE FUNCTION todo_fn_api.delete_todo(_todo_id uuid)
  RETURNS boolean
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval boolean;
  BEGIN
    _retval := todo_fn.delete_todo(_todo_id);
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.delete_todo(_todo_id uuid)
  RETURNS boolean
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _parent_child_count integer;
    _todo todo.todo;
  BEGIN
    perform todo_fn.delete_todo(id) from todo.todo where parent_todo_id = _todo_id;
    
    select * into _todo from todo.todo where id = _todo_id;

    if _todo.parent_todo_id is not null then
      _parent_child_count := (select count(*) from todo.todo where parent_todo_id = _todo.parent_todo_id);
    else
      _parent_child_count := -1;
    end if;
    delete from todo.todo where id = _todo_id;

    if _parent_child_count = 1 then
      update todo.todo set type = 'task' where id = _todo.parent_todo_id;
    end if;

    return true;
  end;
  $$;

---------------------------------------------- pin_todo
CREATE OR REPLACE FUNCTION todo_fn_api.pin_todo(_todo_id uuid)
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval todo.todo;
  BEGIN
    _retval := todo_fn.pin_todo(_todo_id);
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.pin_todo(_todo_id uuid)
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _todo todo.todo;
  BEGIN
    update todo.todo set pinned = true where id = _todo_id returning * into _todo;
    return _todo;
  end;
  $$;

---------------------------------------------- unpin_todo
CREATE OR REPLACE FUNCTION todo_fn_api.unpin_todo(_todo_id uuid)
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval todo.todo;
  BEGIN
    _retval := todo_fn.unpin_todo(_todo_id);
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.unpin_todo(_todo_id uuid)
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _todo todo.todo;
  BEGIN
    update todo.todo set pinned = false where id = _todo_id returning * into _todo;
    return _todo;
  end;
  $$;

---------------------------------------------- assign_todo
CREATE OR REPLACE FUNCTION todo_fn_api.assign_todo(_todo_id uuid, _app_user_tenancy_id uuid)
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval todo.todo;
  BEGIN
    _retval := todo_fn.assign_todo(_todo_id, _app_user_tenancy_id);
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.assign_todo(_todo_id uuid, _app_user_tenancy_id uuid)
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _todo todo.todo;
  BEGIN
    update todo.todo set app_user_tenancy_id = _app_user_tenancy_id where id = _todo_id returning * into _todo;
    return _todo;
  end;
  $$;


---------------------------------------------- search_todos
CREATE OR REPLACE FUNCTION todo_fn_api.search_todos(_options todo_fn.search_todos_options)
  RETURNS setof todo.todo
  LANGUAGE plpgsql
  stable
  SECURITY INVOKER
  AS $$
  DECLARE
  BEGIN
    return query select * from todo_fn.search_todos(_options, auth_ext.app_tenant_id());
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.search_todos(_options todo_fn.search_todos_options, _app_tenant_id uuid)
  RETURNS setof todo.todo
  LANGUAGE plpgsql
  stable
  SECURITY INVOKER
  AS $$
  DECLARE
    _use_options todo_fn.search_todos_options;
  BEGIN
    -- TODO: add paging options
    raise exception 'ati: %', _app_tenant_id;

    return query
    select t.* 
    from todo.todo t
    join app.app_tenant a on a.id = t.app_tenant_id
    where t.app_tenant_id = _app_tenant_id
    and (
      _options.search_term is null 
      or t.name like '%'||_options.search_term||'%'
      or t.description like '%'||_options.search_term||'%'
      or a.name like '%'||_options.search_term||'%'
    )
    and (_options.todo_type is null or t.type = _options.todo_type)
    and (_options.todo_status is null or t.status = _options.todo_status)
    and (coalesce(_options.roots_only, false) = false or t.parent_todo_id is null )
    ;
  end;
  $$;

