# DD Generator with Flyway and Bash
### Problem: 
Generating data dictionary from scratch

### Pre-requisites: 
- Using flyway for migrations
- Installed docker and docker-compose

### How to use
```
./init.sh
```

# Interesting 
`psql -t` means to pset tuples_only (no header and no footer)
`psql -c` to run one psql command
`psql -f` to run one psql file

# Enhancements
[x] specify database and schema
[x] get index
[x] get primary key

1. combine table json output for table
2. get foreign key

