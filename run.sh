#!/bin/bash

set -e 

setup() {
    POSTGRES_CONTAINER=$(docker ps -f name="db" -q)
    SCHEMA=public
    DATABASE=feedback
    OUTPUT_FOLDER=output
    TABLES_FILE=tables.log
    COLUMN_TMP_FILE=columns.jsonl
    rm -f "$COLUMN_TMP_FILE"
    mkdir -p "$OUTPUT_FOLDER"
}

get_tables() {
    docker exec $POSTGRES_CONTAINER psql -t -U postgres -d postgres -f './tmp/get_tables.sql' | xargs -n 1 > $TABLES_FILE
}

generate_columns() {
    sed 's/$TABLE_NAME/'"$TABLE_NAME"'/g;s/$SCHEMA_NAME/'"$SCHEMA_NAME"'/g'  scripts/get_columns.template.sql > scripts/get_columns.sql
    docker exec $POSTGRES_CONTAINER psql -t -U postgres -d postgres -f './tmp/get_columns.sql' | awk -F"|" '$1!=""{print "{\"column_name\": \""$1"\", \"data_type\": \""$2"\", \"primary\": \"\", \"nullable\": \""$3"\", \"description\": \"\", \"identity\": \""$4"\", \"character_max_length\": \""$5"\", \"numeric_precision\": \""$6"\", \"numeric_scale\": \""$7"\", \"numeric_precision_radix\": \""$8"\" }" }' >> "$COLUMN_TMP_FILE"
}

generate_indexes() {
    sed 's/$TABLE_NAME/'"$TABLE_NAME"'/g;' scripts/get_indexes.template.sql > scripts/get_indexes.sql
    docker exec $POSTGRES_CONTAINER psql -t -U postgres -d postgres -f './tmp/get_indexes.sql' | xargs | tr " " ","
}

generate_table() {
    # add comma to end of each line except last line (jsonl -> json)
    COLUMNS=$(sed -e "$ ! s/$/,/" "$COLUMN_TMP_FILE")
    
    INDEXES=$(generate_indexes)

    jq --null-input \
    --arg TABLE_NAME "$TABLE_NAME" \
    --arg SCHEMA_NAME "$SCHEMA_NAME" \
    --arg INDEXES "$INDEXES" \
    --argjson COLUMNS "[$COLUMNS]" \
    '$ARGS.named' > $OUTPUT_FOLDER/$TABLE_NAME.json

    rm "$COLUMN_TMP_FILE"
}

main() {
    setup

    get_tables

    while IFS= read -r line
    do
        SCHEMA_NAME=$(echo "$line" | awk -F "." '{print $1}')
        TABLE_NAME=$(echo "$line" | awk -F "." '{print $2}')
        generate_columns
        generate_table
        echo "$line output done"
    done < "$TABLES_FILE"
}

main