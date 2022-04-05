select
    kcu.column_name as key_column
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu 
     on kcu.constraint_name = tc.constraint_name
     and kcu.constraint_schema = tc.constraint_schema
     and kcu.constraint_name = tc.constraint_name
where 
    tc.constraint_type = 'PRIMARY KEY' and tc.table_name='$TABLE_NAME';