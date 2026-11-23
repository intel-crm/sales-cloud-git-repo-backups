import { LightningElement, api } from 'lwc';
import { exportAsCSV } from 'c/pRM_Utils';

export default class Csvexportbutton extends LightningElement {
    @api isDataAvailable = false;
    @api sampledatasetname = 'Sample Data Set';
    @api currentpage = 0;

    @api exportData = [{'Name': 'Varun'}, {'Name': 'Shivini'}];

    handleExport(){
        exportAsCSV(this.sampledatasetname, this.currentpage, this.exportData);
    }
}