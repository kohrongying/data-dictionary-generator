#!/bin/bash

set -e 

setup() {
    export POSTGRES_CONTAINER=$(docker ps -f name="db" -q)
    export SCHEMA=public
    export DATABASE=feedback
    TABLES_FILE=tables.log
}

get_tables() {
    docker exec $POSTGRES_CONTAINER psql -t -U postgres -d postgres -f './tmp/get_tables.sql' | tail -n +3 | xargs -n 1 > $TABLES_FILE
}

generate_columns() {
    TABLE_NAME=$1
    QUERY="SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='public' AND TABLE_NAME='$TABLE_NAME'"
    docker exec $POSTGRES_CONTAINER psql -t -U postgres -d postgres -c "$QUERY" | awk -F"|" '$1!=""{print "{\"column_name\": \""$1"\", \"data_type\": \""$2"\", \"primary\": \"\", \"nullable\": \""$3"\", \"description\": \"\"}"}' >> columns.jsonl
}

generate_table() {
    COLUMNS=$(sed -e "$ ! s/$/,/" columns.jsonl)

    jq --null-input \
    --arg TABLE_NAME "$TABLE_NAME" \
    --argjson COLUMNS "[$COLUMNS]" \
    '$ARGS.named' > output/$TABLE_NAME.json

    rm columns.jsonl
}


main() {
    setup

    get_tables

    while IFS= read -r line
    do
        TABLE_NAME="$line"
        generate_columns $TABLE_NAME
        generate_table $TABLE_NAME
        echo "$line output done"
    done < "$TABLES_FILE"
}

main