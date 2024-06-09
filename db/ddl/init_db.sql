CREATE EXTENSION if not exists aws_s3 CASCADE;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'staging') THEN
        EXECUTE 'CREATE SCHEMA staging';
    END IF;
END $$;