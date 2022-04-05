SELECT 
    concat(TABLE_SCHEMA,'.',TABLE_NAME) 
FROM 
    INFORMATION_SCHEMA.TABLES
WHERE
    TABLE_SCHEMA != 'pg_catalog' and TABLE_SCHEMA != 'information_schema';