const exportAsCSV = (dataSetName, pageNo, dataSet) => {

    let rowEnd = '\n';
    let csvString = '';
    let rowData = new Set();
    // console.log('Dataset :' + dataSet + ' page no :' + pageNo + ' Dataset name :' + dataSetName);
    if (dataSet === undefined || dataSet === '' || dataSet === null) {
        console.log('Error receiving dataset..');
    } else {
        dataSet.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            })
        })

        rowData = Array.from(rowData);
        csvString += rowData.join(',');
        csvString += rowEnd;

        for (let i = 0; i < dataSet.length; i++) {
            let colValue = 0;
            for (let key in rowData) {
                if (rowData.hasOwnProperty(key)) {
                    let rowKey = rowData[key];
                    if (colValue > 0) {
                        csvString += ',';
                    }
                    let value = dataSet[i][rowKey] === undefined ? '' : dataSet[i][rowKey];
                    csvString += '"' + value + '"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
        let universalBOM = '\uFEFF';
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(universalBOM + csvString);
        downloadElement.target = '_self';

        let downloadDatasetName = dataSetName + pageNo + '.csv';

        downloadElement.download = downloadDatasetName;
        document.body.appendChild(downloadElement);
        downloadElement.click();

    }
}

export { exportAsCSV };