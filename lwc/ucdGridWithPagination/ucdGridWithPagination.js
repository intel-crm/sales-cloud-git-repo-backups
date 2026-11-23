import { LightningElement, track, api } from "lwc";
import { getRecord } from 'lightning/uiRecordApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import {
  NavigationMixin
} from 'lightning/navigation';
export default class UcdGridWithPagination extends NavigationMixin(LightningElement) {
  accountObject = ACCOUNT_OBJECT;
  @api recId;
  @api recName;
  @api config = {};
  tableData = [];
  error = null;
  @track pageIndex = 1;
  perpage = 4;
  @track pageNumbers = [];
  set_size = 5;
  columns = [];

  @track record = {};
  @track unselectcheckbox = [];
  @track ShowModal = false;
  @track spinner = true;
  processConfig() {
    if (
      this.config.hasOwnProperty("page-size") ||
      this.config.hasOwnProperty("pagesize")
    ) {
      this.perpage = this.config["page-size"] || this.config.pagesize;
    }
    if (this.config.hasOwnProperty("columns")) {
      this.columns = this.config["columns"] || this.config.columns;
    }
    if (this.config.hasOwnProperty("data")) {
      this.tableData = this.config["data"] || this.config.data;
    }
  }

  renderedCallback() {
    this.renderButtons();
  }

  renderButtons = () => {
    this.template.querySelectorAll("button").forEach((but) => {
      but.style.backgroundColor =
        this.pageIndex === parseInt(but.dataset.id, 10)
          ? "dodgerblue"
          : "white";
      but.style.color =
        this.pageIndex === parseInt(but.dataset.id, 10)
          ? "white"
          : "rgb(0, 112,210)";
    });
  };

  get pagesList() {
    let mid = Math.floor(this.set_size / 2) + 1;
    if (this.pageIndex > mid && this.pageIndex > this.set_size) {
      return this.pageNumbers.slice(
        this.pageIndex - mid,
        this.pageIndex + mid - 1
      );
    }
    return this.pageNumbers.slice(0, this.set_size);
  }

  connectedCallback() {
    this.processConfig();
    this.setPages(this.tableData);
  }

  pageData = () => {
    let pageIndex = this.pageIndex;
    let perpage = this.perpage;
    let startIndex = pageIndex * perpage - perpage;
    let endIndex = pageIndex * perpage;
    return this.tableData.slice(startIndex, endIndex);
  };

  setPages = (data) => {
    let numberOfPages = Math.ceil(data.length / this.perpage);
    for (let index = 1; index <= numberOfPages; index++) {
      this.pageNumbers.push(index);
    }
  };

  get isFirst() {
    return this.pageIndex === 1;
  }

  get isLast() {
    return (
      this.pageIndex === this.pageNumbers.length ||
      this.pageNumbers.length === 0
    );
  }

  onNext = () => {
    ++this.pageIndex;
  };

  onPrev = () => {
    --this.pageIndex;
  };

  onFirst = () => {
    this.pageIndex = 1;
  };

  onLast = () => {
    this.pageIndex = this.pageNumbers.length;
  };

  onPageClick = (e) => {
    this.pageIndex = parseInt(e.target.dataset.id, 10);
  };

  get currentPageData() {
    this.spinner = false;
    return this.pageData();
  }

  get pageColumns() {
    return this.tableData.length > 0 ? this.columns : [];
  }

  rbselect = (e) => {
    alert(e.target.value);
  };

  getSelectedRow(event) {
    const selectedRows = event.detail.selectedRows;
    for (let i = 0; i < selectedRows.length; i++){
      console.log("You selected: " + selectedRows[i].AcctName);
      const row = event.detail.row;
    }
    //alert('selectedRows'+selectedRows);
    const onSelectRowClick = new CustomEvent("rowselection", { detail: selectedRows});
    this.dispatchEvent(onSelectRowClick);    // Display that fieldName of the selected rows
    
}
//Below function is used to get the record id when the Salesforce Id is clicked from the UI
handleRowAction(event){
  let row = event.detail.row;
  this.recId = row.RecordID;
  this.recName = row.AcctName;
  this.ShowModal = true;  
  
}
  userConfirmChkHandler(){
   
  //this.unselectcheckbox = [];
  }

  //Below function is used to the close the modal
  closeModal() {
    this.ShowModal = false;
}
handleSuccess(event) {
  console.log('Record iD' + event.detail.id);

}
}