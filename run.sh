#!/bin/bash

set -e 
# get absolute path for migration

# POSTGRES_CONTAINER=$(docker ps -f name="db" -q)
setup() {
    docker-compose up -d 
    sleep 30
}
get_tables(){
    docker exec dd_db_1 psql -t -U postgres -d postgres -f './tmp/get_tables.sql' | tail -n +3 | xargs -n 1 > tables.log
}

export SCHEMA=public
export DATABASE=feedback

main() {
    get_tables
    input="tables.log"
    while IFS= read -r line
    do
        TABLE_NAME="$line"
        get_columns $TABLE_NAME
        generate_table $TABLE_NAME
        echo "$line"
    done < "$input"
}

get_columns() {
    TABLE_NAME=$1
    QUERY="SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='public' AND TABLE_NAME='$TABLE_NAME'"
    docker exec dd_db_1 psql -t -U postgres -d postgres -c "$QUERY" | awk -F"|" '$1!=""{print "{\"column_name\": \""$1"\", \"data_type\": \""$2"\", \"primary\": \"\", \"nullable\": \""$3"\", \"description\": \"\"}"}' >> columns.jsonl
}

generate_column() {
    COLUMN_NAME=$1
    DATA_TYPE=$2
    jq --null-input \
        --arg COLUMN_NAME "$COLUMN_NAME" \
        --arg DATA_TYPE "$DATA_TYPE" \
        --arg PRIMARY "True" \
        --arg NULLABLE "True" \
        --arg DESCRIPTION "some desc" \
        '{"column_name": $COLUMN_NAME, "data_type": $DATA_TYPE, "primary": $PRIMARY, "nullable": $NULLABLE, "description": $DESCRIPTION}'
}


generate_table() {
    COLUMNS=$(sed -e "$ ! s/$/,/" columns.jsonl)

    jq --null-input \
    --arg TABLE_NAME "$TABLE_NAME" \
    --argjson COLUMNS "[$COLUMNS]" \
    '$ARGS.named' > output/$TABLE_NAME.json
    rm columns.jsonl
}


main