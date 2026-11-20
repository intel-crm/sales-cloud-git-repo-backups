import { LightningElement, api, track } from "lwc";
import PRM_PrevPage from "@salesforce/label/c.PRM_PrevPage";
import PRM_PageGrid from "@salesforce/label/c.PRM_PageGrid";
import PRM_NextPage from "@salesforce/label/c.PRM_NextPage";
import PRM_GoToPage from "@salesforce/label/c.PRM_GoTooPage";

const DELAY = 0;
const recordsPerPage = [5, 10, 25, 50, 100];
const pageNumber = 1;
const showIt = "visibility:visible";
const hideIt = "visibility:hidden"; //visibility keeps the component space, but display:none doesn't

export default class PaginationGridFooter extends LightningElement {
	@api showPagination; //Show/hide pagination; valid values are true/false
	@api pageSizeOptions = recordsPerPage; //Page size options; valid values are array of integers
	@api totalRecords; //Total no.of records; valid type is Integer
	@api records; //All records available in the data table; valid type is Array
	@track pageSize; //No.of records to be displayed per page
	@track totalPages; //Total no.of pages
	@track pageNumber = pageNumber; //Page number
	@track searchKey; //Search Input
	@track controlPagination = showIt;
	@track controlPrevious = hideIt; //Controls the visibility of Previous page button
	@track controlNext = showIt; //Controls the visibility of Next page button
	@track SearchRecords;

	formLabels = {
		PRM_PrevPage,
		PRM_PageGrid,
		PRM_NextPage,
		PRM_GoToPage
	};

	connectedCallback() {
		if (this.pageSizeOptions && this.pageSizeOptions.length > 0) this.pageSize = this.pageSizeOptions[0];
		else {
			this.pageSize = this.totalRecords;
			this.showPagination = false;
		}
		this.controlPagination = this.showPagination === false ? hideIt : showIt;
		this.SearchRecords = this.records;
		this.setRecordsToDisplay();
	}
	handleRecordsPerPage(event) {
		this.pageSize = event.target.value;
		this.setRecordsToDisplay();
	}
	handlePageNumberChange(event) {
		this.pageNumber = event.target.value;
		this.setRecordsToDisplay();
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
		if (!this.pageSize) this.pageSize = this.totalRecords;
		if (this.SearchRecords.length > 0) {
			this.totalPages = Math.ceil(this.SearchRecords.length / this.pageSize);

			this.setPaginationControls();

			for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
				if (i === this.SearchRecords.length) break;
				this.recordsToDisplay.push(this.SearchRecords[i]);
			}
		} else {
			this.totalPages = 0;
			this.pageNumber = 0;
			this.controlPagination = hideIt;
			this.setPaginationControls();
		}
		this.dispatchEvent(new CustomEvent("paginatorchangefooter", { detail: { rec: this.recordsToDisplay, paginate: true } })); //Send records to display on table to the parent component
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
	handleKeyChange(search) {
		window.clearTimeout(this.delayTimeout);
		const searchKey = search.toLowerCase();
		if (searchKey && searchKey.length > 2) {
			this.delayTimeout = setTimeout(() => {
				this.controlPagination = showIt;

				this.searchKey = searchKey;
				//Use other field name here in place of 'Name' field if you want to search by other field
				//this.recordsToDisplay = this.records.filter(rec => rec.includes(searchKey));
				//Search with any column value (Updated as per the feedback)
				this.SearchRecords = this.records.filter((rec) => {
					return (
						(rec.Email && JSON.stringify(rec.Name.toLowerCase()).includes(searchKey)) ||
						(rec.Email && JSON.stringify(rec.Email.toLowerCase()).includes(searchKey)) ||
						(rec.Status && JSON.stringify(rec.Status.toLowerCase()).includes(searchKey))
					);
				});
				this.setRecordsToDisplay();

				//if (Array.isArray(this.recordsToDisplay)) this.dispatchEvent(new CustomEvent("paginatorchangefooter", { detail: { rec: this.recordsToDisplay, paginate: true } }));
				//Send records to display on table to the parent component
			}, DELAY);
		} else {
			this.controlPagination = showIt;
			this.SearchRecords = this.records;
			this.setRecordsToDisplay();
		}
	}
	@api setRecordData(data, search, pageSize) {
		this.totalRecords = data.length;
		if (search) {
			this.controlPagination = showIt;
			this.pageSize = pageSize;
			this.handleKeyChange(search);
		} else {
			this.pageSize = pageSize;
			this.controlPagination = showIt;
			this.SearchRecords = data;
			this.setRecordsToDisplay();
		}
	}
}