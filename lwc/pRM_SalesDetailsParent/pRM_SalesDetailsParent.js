import { LightningElement, track, api } from 'lwc';
import PRM_SalesDetailsExt_Style from '@salesforce/resourceUrl/PRM_SalesDetailsExt_Style'
import { loadStyle } from 'lightning/platformResourceLoader'
const PAGE_SIZE = 200;
export default class PRM_SalesDetailsParent extends LightningElement {

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
    // @api page = 1;
    // @api totalrecords;
    // @api _pagesize = PAGE_SIZE;
    // @api _hasRender;
    // get pagesize() {
    //     return this._pagesize;
    // }
    // set pagesize(value) {
    //     this._pagesize = value;
    // }
    // handlePrevious() {

    //     this.hasRender = false;
    //     console.log('From handle prev :' + this.hasRender);
    //     if (this.page > 1) {
    //         this.page = this.page - 1;
    //     }
    // }
    // handleNext() {
    //     this.hasRender = false;
    //     console.log('From handle next :' + this.hasRender);
    //     if (this.page < this.totalPages)
    //         this.page = this.page + 1;
    // }
    // handleFirst() {
    //     this.hasRender = false;
    //     this.page = 1;
    // }
    // handleLast() {
    //     this.hasRender = false;
    //     this.page = this.totalPages;
    // }
    // handleRecordsLoad(event) {
    //     this.totalrecords = event.detail;
    //     this.totalPages = Math.ceil(this.totalrecords / this.pagesize);
    // }
    // handlePageChange(event) {

    //     console.log('Here you are setting render :' + this.hasRender);
    //     this.page = event.detail;

    // }
}