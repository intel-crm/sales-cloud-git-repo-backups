import { LightningElement, api, track } from "lwc";
import PRM_RecordsPerPage from "@salesforce/label/c.PRM_RecordsPerPage";

const DELAY = 100;
const recordsPerPage = [5, 10, 25, 50, 100];
const showIt = "visibility:visible";
const hideIt = "visibility:hidden"; //visibility keeps the component space, but display:none doesn't

export default class Pagination extends LightningElement {
	@api showSearchBox = false; //Show/hide search box; valid values are true/false
	@api showPagination; //Show/hide pagination; valid values are true/false
	@api pageSizeOptions = recordsPerPage; //Page size options; valid values are array of integers
	@track totalPages; //Total no.of pages
	@track searchKey; //Search Input
	@track controlPagination = showIt;
	@api searchPlaceHolderText;
	formLabels = {
		PRM_RecordsPerPage
	};

	//Called after the component finishes inserting to DOM
	connectedCallback() {
		if (this.pageSizeOptions && this.pageSizeOptions.length > 0) this.pageSize = this.pageSizeOptions[0];
		else {
			this.pageSize = this.totalRecords;
			this.showPagination = false;
		}
		this.controlPagination = this.showPagination === false ? hideIt : showIt;
		this.setRecordsToDisplay();
	}

	handleRecordsPerPage(event) {
		this.pageSize = event.target.value;
		this.setRecordsToDisplay();
	}
	setRecordsToDisplay() {
		this.dispatchEvent(new CustomEvent("paginatorchange", { detail: { search: this.searchKey, pageSize: this.pageSize } })); //Send records to display on table to the parent component
	}
	handleKeyChange(event) {
		window.clearTimeout(this.delayTimeout);
		const searchKey = event.target.value.toLowerCase();
		if (searchKey && searchKey.length > 2) {
			this.delayTimeout = setTimeout(() => {
				this.controlPagination = showIt;
				this.searchKey = searchKey;
				this.dispatchEvent(new CustomEvent("paginatorchange", { detail: { search: this.searchKey, pageSize: this.pageSize } }));

				//Send records to display on table to the parent component
			}, DELAY);
		} else {
			this.searchKey = searchKey;
			this.controlPagination = showIt;
			this.setRecordsToDisplay();
		}
	}
}