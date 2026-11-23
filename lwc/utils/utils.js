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
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        let downloadDatasetName = dataSetName + pageNo + '.csv';
        // let browser = Window.browser || Window.chrome;
        // let searching = browser.downloads.search({ downloadDatasetName });
        // console.log('File name :' + searching);
        // searching.then(logDownloads, onError);
        // if (searching === null || searching === undefined || Object.isEmpty(searching)) {
        downloadElement.download = downloadDatasetName;
        document.body.appendChild(downloadElement);
        downloadElement.click();
        // } else {
        //     console.log('You are inside repeat file');
        //     let retVal = window.confirm('File with ' + downloadDatasetName + ' name already exit! Do you want to download?');
        //     if (retVal == 'Ok' || retVal == 'ok') {
        //         downloadElement.download = downloadDatasetName;
        //         document.body.appendChild(downloadElement);
        //         downloadElement.click();
        //     }
        // }

    }

    // function logDownloads(downloads) {
    //     for (let download of downloads) {
    //         console.log(download.id);
    //         console.log(download.url);
    //     }
    // }
    // function onError(error) {
    //     console.log(`Error: ${error}`);
    // }
}

export { exportAsCSV };