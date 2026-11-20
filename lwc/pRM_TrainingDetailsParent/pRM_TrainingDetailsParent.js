import { LightningElement, track, api } from 'lwc';
import pgSize from '@salesforce/label/c.PRM_SOD_Training_Page_Size';
import PRM_SalesDetailsExt_Style from '@salesforce/resourceUrl/PRM_SalesDetailsExt_Style'
import { loadStyle } from 'lightning/platformResourceLoader'
export default class PRM_TrainingDetails extends LightningElement {
    @api page = 1;
    @api totalrecords = 0;
    @api _pagesize = pgSize;
    get pagesize() {
        return this._pagesize;
    }
    set pagesize(value) {
        this._pagesize = value;
    }
    handlePrevious() {
        if (this.page > 1) {
            this.page = this.page - 1;
        }
    }
    handleNext() {
        if (this.page < this.totalPages)
            this.page = this.page + 1;
    }
    handleFirst() {
        this.page = 1;
    }
    handleLast() {
        this.page = this.totalPages;
    }
    handleRecordsLoad(event) {
        this.totalrecords = event.detail;
        this.totalPages = Math.ceil(this.totalrecords / this.pagesize);
    }
    handlePageChange(event) {
        this.page = event.detail;
    }
    renderedCallback() {
        if (this.isCssLoaded)
        return
        this.isCssLoaded = true
            loadStyle(this, PRM_SalesDetailsExt_Style)
            // loadStyle(this, Core_INTC + '/theme/styles/corebundle.min.css')
        .then(() => {
        console.log("Loaded Successfully")
        })
        .catch(error => {
            console.error("Error in loading the colors")
        })
    }
}