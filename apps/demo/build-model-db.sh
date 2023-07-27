#!/usr/bin/env bash
psql -h 0.0.0.0 -U postgres -c 'drop database snp;'
psql -h 0.0.0.0 -U postgres -c 'create database snp;'

psql -h 0.0.0.0 -U postgres -d snp -f ./supabase/auth-stub.sql
psql -h 0.0.0.0 -U postgres -d snp -f ./supabase/migrations/20230703174540_extensions.sql
psql -h 0.0.0.0 -U postgres -d snp -f ./supabase/migrations/20230703174545_app.sql
psql -h 0.0.0.0 -U postgres -d snp -f ./supabase/migrations/20230703175424_todo.sql
