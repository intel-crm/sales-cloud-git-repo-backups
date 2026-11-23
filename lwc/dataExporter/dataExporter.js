import { LightningElement } from 'lwc';

export default class DataExporter extends LightningElement {
    handleFileUpload(event) {
     const file = event.target.files[0];
     console.log('OUTPUT : ',file);
     if (file) {
            const reader = new FileReader();

            reader.onload = (e) => {
                const data = e.target.result;
                const workbook = XLSX.read(data, { type: 'binary' });
                const sheetName = workbook.SheetNames[0];
                const sheet = workbook.Sheets[sheetName];
                const jsonData = XLSX.utils.sheet_to_json(sheet);

                this.jsonOutput = JSON.stringify(jsonData, null, 2);
            };

            console.log('OUTPUT JSON: ',this.jsonOutput);

            reader.readAsBinaryString(file);
        }
    }
}