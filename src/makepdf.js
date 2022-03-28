const constants = require('./constants')

const buildTable = (data) => {
    const table_name = data.TABLE_NAME;
    const HEADERS = [
        'S/N', 'PK', 'Column Name', 'Data Type', 'Nullable', 'Description'
    ]
    const widths = [
        100, 100, '*', '*', 200, '*'
    ]
    const body = [HEADERS]
    data.COLUMNS.forEach((column, index) => {
        body.push([
            `${index+1}`, "", column.column_name, column.data_type, column.nullable, column.description
        ])
    })

    return {
        stack: [
            { text: `Project: ${constants.PROJECT_NAME}` },
            { text: `Database: Feedback` },
            { text: `Table: ${table_name}`, margin: [0, 0, 0, 10] },
            { 
                table: { 
                    widths,
                    body, 
                },
                margin: [0, 0, 0, 20]
            }
        ]
    }
}


const buildDoc = (data) => {
    console.time('total')  
    const docDefinition = {
      pageSize: { // 16:9 dimension
        width: constants.PAGE_WIDTH,
        height: constants.PAGE_HEIGHT,
      },
      pageOrientation: 'landscape',
      content: [
        buildTable(data)
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