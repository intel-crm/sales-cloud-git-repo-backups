import { LightningElement, api, track } from 'lwc';
import { exportAsCSV } from 'c/pRM_Utils';
export default class ExportAsCSVLwc extends LightningElement {
    @api isDataAvailable = false;
    @api newdataSetName = 'Test Data Set';
    @api currentPage = 0;
    @track exportBtnLbl = 'Export as CSV';
    // create method for testing with data

    @api exportData = [];


    handleExport() {
        exportAsCSV(this.newdataSetName, this.currentpage, this.exportData);
    }
}