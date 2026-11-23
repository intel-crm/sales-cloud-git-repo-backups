import { LightningElement, api, track} from 'lwc';
import noRecordsToDisplay from '@salesforce/label/c.Core_MDF_NoRecordsToDisplay';
import page from '@salesforce/label/c.Core_MDF_Page';
import recPerPage from '@salesforce/label/c.Core_MDF_Records_Per_Page';

const DELAY = 300;
const recordsPerPage = [10,25,50,100];
const pageNumber = 1;
//const showIt = 'visibility:visible';
//const hideIt = 'visibility:hidden'; //visibility keeps the component space, but display:none doesn't
export default class core_MDF_Paginator extends LightningElement {
    @api showSearchBox = false; //Show/hide search box; valid values are true/false
    @api showPagination; //Show/hide pagination; valid values are true/false
    @api pageSizeOptions = recordsPerPage; //Page size options; valid values are array of integers
    @api totalRecords; //Total no.of records; valid type is Integer
    @api records; //All records available in the data table; valid type is Array 
    @track pageSize; //No.of records to be displayed per page
    @track totalPages; //Total no.of pages
    @track pageNumber = pageNumber; //Page number
    @track searchKey; //Search Input
    @track showPaginationComponent = true;
    @track initialLoad = true;
    @track recordsPerPageChanged = false;
    //@track controlPagination = showIt;
    //@track controlPrevious = hideIt; //Controls the visibility of Previous page button
    //@track controlNext = showIt; //Controls the visibility of Next page button
    recordsToDisplay = []; //Records to be displayed on the page
    label = {noRecordsToDisplay,recPerPage,page};
    @track paginatorHasRendered = false;
    //@track currentRecordsPerPage;

    //Called after the component finishes inserting to DOM
    connectedCallback() {
        //this.currentRecordsPerPage = this.pageSizeOptions[0];
        if(this.pageSizeOptions && this.pageSizeOptions.length > 0) 
            this.pageSize = this.pageSizeOptions[0];
        else{
            this.pageSize = this.totalRecords;
            this.showPagination = false;
        }
       // this.controlPagination = this.showPagination === false ? hideIt : showIt;
        this.setRecordsToDisplay();
    }

    renderedCallback(){
        if(this.paginatorHasRendered){
            this.template.querySelector("select").selectedIndex = this.pageSizeOptions.indexOf(parseInt(this.pageSize));
        }
    }

    handleRecordsPerPage(event){         
        this.recordsPerPageChanged = true;
        this.pageSize = event.target.value;
        //this.currentRecordsPerPage = this.pageSize;
        this.setRecordsToDisplay();
    }
    handlePageNumberChange(event){
        if(event.keyCode === 13){
            this.pageNumber = event.target.value;
            this.setRecordsToDisplay();
        }
    }
    previousPage(){
        this.pageNumber = this.pageNumber-1;
        this.setRecordsToDisplay();
    }
    nextPage(){
        this.pageNumber = this.pageNumber+1;
        this.setRecordsToDisplay();
    }
    setRecordsToDisplay(){

        this.recordsToDisplay = [];
        if(!this.pageSize)
            this.pageSize = this.totalRecords;       
        this.totalPages = Math.ceil(this.totalRecords/this.pageSize);
        this.setPaginationControls();
            
        this.showPaginationComponent = (this.records.length > 0) ? true : false;
        this.paginatorHasRendered = (this.showPaginationComponent) ? true : false;

        for(let i=(this.pageNumber-1)*this.pageSize; i < this.pageNumber*this.pageSize; i++){
            if(i === this.totalRecords) break;
            this.recordsToDisplay.push(this.records[i]);
        }
        this.dispatchEvent(new CustomEvent('paginatorchange', {detail: this.recordsToDisplay})); //Send records to display on table to the parent component
    }
    setPaginationControls(){
        //Control Pre/Next buttons visibility by Total pages
   /*     if(this.totalPages === 1){
           // this.controlPrevious = hideIt;
           // this.controlNext = hideIt;
        }else if(this.totalPages > 1){
          // this.controlPrevious = showIt;
          // this.controlNext = showIt;
        }*/
        //Control Pre/Next buttons visibility by Page number
        if(this.pageNumber <= 1){
            this.pageNumber = 1;
           // this.controlPrevious = hideIt;
        }else if(this.pageNumber >= this.totalPages){
            this.pageNumber = this.totalPages;
           // this.controlNext = hideIt;
        }
        //Control Pre/Next buttons visibility by Pagination visibility
        //if(this.controlPagination === hideIt){
        //    this.controlPrevious = hideIt;
        //    this.controlNext = hideIt;
        //}
    }
    handleKeyChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        if(searchKey){
            this.delayTimeout = setTimeout(() => {
                //this.controlPagination = hideIt;
                this.setPaginationControls();

                this.searchKey = searchKey;
                //Use other field name here in place of 'Name' field if you want to search by other field
                //this.recordsToDisplay = this.records.filter(rec => rec.includes(searchKey));
                //Search with any column value (Updated as per the feedback)
                this.recordsToDisplay = this.records.filter(rec => JSON.stringify(rec).toLowerCase().includes(searchKey.toLowerCase()));
                if(Array.isArray(this.recordsToDisplay) && this.recordsToDisplay.length > 0)
                    this.dispatchEvent(new CustomEvent('paginatorchange', {detail: this.recordsToDisplay, perPageChanged: this.recordsPerPageChanged})); //Send records to display on table to the parent component
            }, DELAY);
        }else{
            //this.controlPagination = showIt;
            this.setRecordsToDisplay();
        }        
    }

    rowSelection(selrows, selection) {
        // Avoid any operation if page has changed
        // as this event will be fired when new data will be loaded in page
        // after clicking on next or prev page
    
        if (!this.hasPageChanged || this.initialLoad) {
          //set initial load to false
          this.initialLoad = false;
    
          //Get currently select rows, This will only give the rows available on 
          //current page
    
          let selectedRows = selrows;
          console.log("==current row---" + JSON.stringify(this.selectedRows));
    
          //Get all selected rows from datatable, this will give all the selected data      //from all the pages
    
          let allSelectedRows = selection;
    
          //Get current page number
          let currentPageNumber = this.pageNumber;
    
          //Process the rows now
          //Condition 1 -If any new row selected, add to our allSelectedRows attribute
          //Condition 2 - any row is deselected, remove from allSelectedRows attribute
          //Solution - Remove all rows from current page from allSelectedRows 
          //attribute and then add again
    
    
          //Removing all rows coming from curent page from allSelectedRows
    
        for(let j = allSelectedRows.length-1 ; j>=0 ; j--){
            let pageNumber = parseInt((allSelectedRows[j].split("-")[1]),10);
            if(pageNumber && pageNumber === currentPageNumber)
                allSelectedRows.splice(j, 1);
        }
    
    
        //Adding all the new selected rows in allSelectedRows
        for(let k=0; k<selectedRows.length; k++){
            allSelectedRows.push(selectedRows[k].Id);
        }
          //Setting new value in selection attribute
          this.selection.push(...allSelectedRows);
          this.selection=[...new Set(this.selection)];
          console.log("==current row---" + JSON.stringify(this.selection));
        }
        else this.hasPageChanged = false;
      }

    /* function to handle Pagination on Search box*/
    @api handlePaginationOnSearch(searchedRecords, totalNoOfRecords ){        
        this.totalRecords = totalNoOfRecords;
        this.records = searchedRecords;
        this.pageNumber = 1;
        this.setRecordsToDisplay(); 
           
    }
}