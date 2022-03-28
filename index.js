const PdfPrinter = require('pdfmake/src/printer');
const fonts = {
	Roboto: {
		normal: 'fonts/Roboto-Regular.ttf',
		bold: 'fonts/Roboto-Medium.ttf',
		italics: 'fonts/Roboto-Italic.ttf',
		bolditalics: 'fonts/Roboto-MediumItalic.ttf'
	}
};
const printer = new PdfPrinter(fonts);
const fs = require('fs');
const {
    buildDoc
  } = require('./src/makepdf');

(async () => {
    try {
        const dataFolder = `${__dirname}/output`
        const docDefinition = buildDoc(dataFolder)
        console.time('print')
        const doc = printer.createPdfKitDocument(docDefinition);

        const outputfile = 'data_dictionary.pdf'
        doc.pipe(fs.createWriteStream(outputfile));
        doc.end();
        console.timeEnd('print')
        console.timeEnd('total')
        console.log(`pdf created successfully`)
    } catch (error) {
        console.log(error)
    }
})();