/*
====================================================================================
Create Database and Schemas
====================================================================================
Script Purpose:
  This script creates a new database named 'DataWarehouse' after checking if it already exists.
  If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within the databse: 
'bronze', 'silver', and 'gold'.

WARNING:
Running this script will drop the entire 'DataWarehouse' database if it exists.
All data in the database will be prmanenlty deleted. Proceed with caution and 
ensure you have proper backups before running this script.

DO
$$
DECLARE
    db_exists BOOLEAN;
BEGIN
    -- 1. Check if the database exists
    SELECT EXISTS(SELECT 1 FROM pg_database WHERE datname = 'datawarehouse')
    INTO db_exists;

    -- 2. If exists, terminate active connections and drop it
    IF db_exists THEN
        RAISE NOTICE 'Dropping existing database "datawarehouse"...';
        PERFORM pg_terminate_backend(pid)
        FROM pg_stat_activity
        WHERE datname = 'datawarehouse';

        EXECUTE 'DROP DATABASE datawarehouse';
    END IF;

    -- 3. Create the database again
    RAISE NOTICE 'Creating new database "datawarehouse"...';
    EXECUTE 'CREATE DATABASE datawarehouse';
END
$$;

-- 4. Create schemas inside the new database
--    (runs in a new session automatically)
DO
$$
BEGIN
    -- Create schema layers (if they don’t exist)
    PERFORM d.oid FROM pg_namespace d WHERE nspname = 'bronze';
    IF NOT FOUND THEN
        EXECUTE 'CREATE SCHEMA bronze';
    END IF;

    PERFORM d.oid FROM pg_namespace d WHERE nspname = 'silver';
    IF NOT FOUND THEN
        EXECUTE 'CREATE SCHEMA silver';
    END IF;

    PERFORM d.oid FROM pg_namespace d WHERE nspname = 'gold';
    IF NOT FOUND THEN
        EXECUTE 'CREATE SCHEMA gold';
    END IF;

    RAISE NOTICE 'Schemas bronze, silver, and gold created successfully.';
END
$$ LANGUAGE plpgsql;
