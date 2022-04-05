const constants = require('./constants')
const fs = require('fs');
const path = require('path');

const buildTable = (data) => {
    const table_name = data.TABLE_NAME;
    const schema_name = data.SCHEMA_NAME;
    
    return {
        stack: [
            { text: `Project: ${constants.PROJECT_NAME}` },
            { text: `Schema: ${schema_name}` },
            { text: `Table: ${table_name}`, margin: [0, 0, 0, 10] },
            buildIndexesTable(data),
            buildColumnsTable(data)
        ]
    }
}

const buildIndexesTable = (data) => {
    const indexes =  data.INDEXES.replace(",","\n")
    const body = [
        ['Index', indexes]
    ]
    const widths = [200, '*']
    return { 
        table: { 
            widths,
            body, 
        },
        margin: [0, 0, 0, 10]
    }
}

const buildColumnsTable = (data) => {
    const PKEYS = data.PKEYS.split(",")
    const HEADERS = [
        'S/N', 'PK', 'Column Name', 'Data Type', 'Max Length', 'Nullable', 'Description'
    ]
    const widths = [
        50, 100, '*', '*', 200, 100, '*'
    ]
    const body = [HEADERS]
    data.COLUMNS.forEach((column, index) => {
        body.push([
            `${index+1}`, 
            PKEYS.includes(column.column_name.trim()) ? "Y" : "", 
            column.column_name, 
            column.data_type,
            column.character_max_length, 
            column.nullable,
            column.description
        ])
    })
    return { 
        table: { 
            widths,
            body, 
        },
        margin: [0, 0, 0, 20]
    }
}

const buildTables = (folder) => {
    let content = []
    fs.readdirSync(folder).forEach(file => {
        filepath = path.resolve(folder, file)
        content.push(buildTable(require(filepath)))
    });
    return content
}

const buildDoc = (dataFolder) => {
    console.time('total')  
    const docDefinition = {
      pageSize: { // 16:9 dimension
        width: constants.PAGE_WIDTH,
        height: constants.PAGE_HEIGHT,
      },
      pageOrientation: 'landscape',
      content: [
        {
            stack: buildTables(dataFolder)
        }
      ],
      defaultStyle: {
        fontSize: constants.DEFAULT_FONT_SIZE
      },
      styles: {
      }
    }
    return docDefinition
  }
    
  module.exports = {
    buildDoc
  }