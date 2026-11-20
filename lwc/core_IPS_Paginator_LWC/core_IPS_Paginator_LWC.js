import { LightningElement, api, track } from 'lwc';
const DELAY = 300;
const recordsPerPage = [10, 25, 50, 100];
const pageNumber = 1;
const showIt = 'visibility:visible';
const hideIt = 'visibility:hidden'; //visibility keeps the component space, but display:none doesn't
export default class Core_IPS_Paginator_LWC extends LightningElement {
    @api showSearchBox = false; //Show/hide search box; valid values are true/false
    @api showPagination; //Show/hide pagination; valid values are true/false
    get pageSizeOptions() {
            return [
                { label: '10', value: 10 },
                { label: '25', value: 25 },
                { label: '50', value: 50 },
                { label: '100', value: 100 },
            ];
        }
        //@api pageSizeOptions = recordsPerPage; //Page size options; valid values are array of integers
    @api totalRecords; //Total no.of records; valid type is Integer
    @api records; //All records available in the data table; valid type is Array 
    @api pageSize = 10; //No.of records to be displayed per page
    @track totalPages; //Total no.of pages
    @track pageNumber = pageNumber; //Page number
    @track searchKey; //Search Input
    @track controlPagination = showIt;
    @track controlPrevious = hideIt; //Controls the visibility of Previous page button
    @track controlNext = showIt; //Controls the visibility of Next page button
    recordsToDisplay = []; //Records to be displayed on the page

    //Called after the component finishes inserting to DOM
    connectedCallback() {
        console.log('inside connected call back of pagiantion', JSON.parse(JSON.stringify(this.records)));
        console.log('pagesize options in connected call back', this.pageSizeOptions);
        if (localStorage.getItem('pageSize')) {
            this.pageSize = parseInt(localStorage.getItem('pageSize'));
        }
        if (!this.pageSize) {
            if (this.pageSizeOptions && this.pageSizeOptions.length > 0)
                this.pageSize = this.pageSizeOptions[0];



            else {
                console.log('pagesize in connected call back', this.pageSize);
                this.pageSize = this.totalRecords;
                // console.log('pagesize in connected call back',this.pageSize);
                this.showPagination = false;
            }
        }
        this.controlPagination = this.showPagination === false ? hideIt : showIt;
        this.setRecordsToDisplay();
    }

    handleRecordsPerPage(event) {
        this.pageSize = parseInt(event.target.value);
        localStorage.setItem('pageSize', this.pageSize);
        this.setRecordsToDisplay();
    }
    handlePageNumberChange(event) {
        if (event.keyCode === 13) {
            this.pageNumber = event.target.value;
            this.setRecordsToDisplay();
        }
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.setRecordsToDisplay();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.setRecordsToDisplay();
    }
    setRecordsToDisplay() {
        this.recordsToDisplay = [];
        if (!this.pageSize)
            this.pageSize = this.totalRecords;

        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);

        this.setPaginationControls();

        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) break;
            this.recordsToDisplay.push(this.records[i]);
        }
        this.dispatchEvent(new CustomEvent('paginatorchange', { detail: this.recordsToDisplay })); //Send records to display on table to the parent component
    }
    setPaginationControls() {
        //Control Pre/Next buttons visibility by Total pages
        if (this.totalPages === 1) {
            this.controlPrevious = hideIt;
            this.controlNext = hideIt;
        } else if (this.totalPages > 1) {
            this.controlPrevious = showIt;
            this.controlNext = showIt;
        }
        //Control Pre/Next buttons visibility by Page number
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
            this.controlPrevious = hideIt;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
            this.controlNext = hideIt;
        }
        //Control Pre/Next buttons visibility by Pagination visibility
        if (this.controlPagination === hideIt) {
            this.controlPrevious = hideIt;
            this.controlNext = hideIt;
        }
    }
    handleKeyChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        if (searchKey) {
            console.log('searchkey', searchKey);
            this.delayTimeout = setTimeout(() => {
                this.controlPagination = hideIt;
                this.setPaginationControls();

                this.searchKey = searchKey;
                this.recordsToDisplay = this.records.filter(rec => JSON.stringify(rec).includes(searchKey));
                if (Array.isArray(this.recordsToDisplay) && this.recordsToDisplay.length > 0)
                    this.dispatchEvent(new CustomEvent('paginatorchange', { detail: this.recordsToDisplay })); //Send records to display on table to the parent component
            }, DELAY);
        } else {
            this.controlPagination = showIt;
            this.setRecordsToDisplay();
        }
    }
}