const exportAsCSV = (dataSetName, pageNo, dataSet) => {

    let rowEnd = '\n';
    let csvString = '';
    let rowData = new Set();
    // console.log('Dataset :' + dataSet + ' page no :' + pageNo + ' Dataset name :' + dataSetName);
    if (dataSet === undefined || dataSet === '' || dataSet === null) {
        console.log('Error receiving dataset..');
    } else {
        console.log(' dataset..'+ dataSet.length);
        dataSet.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            })
        })

        rowData = Array.from(rowData);
        csvString += '<table border=1><tr>';
        for (let i = 0; i < rowData.length; i++){
            csvString += '<td>'+rowData[i] + '</td>';
        }
        csvString += '</tr>';
        csvString += rowEnd;
        console.log('rowData'+rowData);
        for (let i = 0; i < dataSet.length; i++) {
            let colValue = 0;
            csvString += '<tr>';
            console.log('i'+i);
            console.log('dataSet-->'+JSON.stringify(dataSet[i]));
            for (let key in rowData) {
                if (rowData.hasOwnProperty(key)) {
                    console.log('i--->'+i);
                    let rowKey = rowData[key];
                    // if (colValue > 0) {
                    //     csvString += ',';
                    // }
                    let value = dataSet[i][rowKey] === undefined ? '<td></td>' :'<td>'+ dataSet[i][rowKey]+'</td>';
                    csvString +=  value;
                    colValue++;
                    console.log('datasetrowkey--->'+dataSet[i][rowKey]);
                }
            }
            csvString += '</tr>';
        }
        csvString += '</table>'
        console.log('csvString'+csvString);
        let universalBOM = '\uFEFF';
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:application/vnd.ms-excel,' + encodeURIComponent(csvString);
        downloadElement.target = '_self';

        let downloadDatasetName = dataSetName + pageNo + '.xls';

        downloadElement.download = downloadDatasetName;
        document.body.appendChild(downloadElement);
        downloadElement.click();

    }
}

export { exportAsCSV };