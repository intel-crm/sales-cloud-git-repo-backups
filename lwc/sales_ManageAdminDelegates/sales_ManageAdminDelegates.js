import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import loggedInUserId from '@salesforce/user/Id';

//CONTROLLER
import getAllDelegates from '@salesforce/apex/Sales_LicenseFileGeneration_Chatbot.getAllDelegates';

//Labels
import errorMsg from '@salesforce/label/c.Sales_Error_Message';                          //Error title

//Actions
const actions = [
    { label: 'Delete', name: 'delete' }
];

//Columns
const columns = [
    { label: 'Delegate Admin First Name', fieldName: 'Sales_License_DelegateAdmin_FirstName__c', type: 'text' },
    { label: 'Delegate Admin Last Name', fieldName: 'Sales_License_DelegateAdmin_LastName__c', type: 'text' },
    { label: 'Delegate Admin Email Address', fieldName: 'Sales_License_DelegateAdmin_Email__c', type: 'email' },
    { type: 'action', typeAttributes: { rowActions: actions }, cellAttributes: { alignment: 'left' } },
];

export default class Sales_ManageAdminDelegates extends LightningElement {

    //Data
    @api columns = columns;
    @api tableHasData = false;
    @track tableData = [];
    //Pagination Fields
    @track items = []; 
    @track page = 1; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 5; 
    @track totalRecountCount = 0;
    @track totalPage = 0;

    //Labels
    label = {
        errorMsg
    };

    connectedCallback() {
        //Get Data for Table on Component Load
        this.handleDataTable();
    }

    handleDataTable() {
        console.log('User Id - ' + loggedInUserId);
        getAllDelegates({ userId: loggedInUserId })
            .then((result) => {
                //console.log('Controller result payload: ' + JSON.stringify(result));
                if (result != null && JSON.stringify(result) != '[]') {
                    this.items = result;
                    this.totalRecountCount = result.length; 
                    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);                           
                    this.tableData = this.items.slice(0,this.pageSize);                  
                    this.endingRecord = this.pageSize;
                    this.page = 1;              //On Deletion or Addition of Records, display 1st page.
                    this.tableHasData = true;
                    this.displayRecordPerPage(this.page);  
                    this.disableEnablePaginationButtons();
                }
                else {
                    this.tableHasData = false;
                    this.tableData = [];
                }
            })
            .catch((error) => {
                //console.log('Error! -- '+JSON.stringify(error));
                this.fireToastEvent(this.label.errorMsg, error.body.message, 'error', 'sticky');  
            });

    }

    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

    //this method displays records page by page
    displayRecordPerPage(page){
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount)  ? this.totalRecountCount : this.endingRecord; 
        this.tableData = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }    

    disableEnablePaginationButtons() {
        let buttons = this.template.querySelectorAll("lightning-button");
        //let buttons = this.template.querySelector('[data-id="paginationButton"]');
        buttons.forEach((bn) => {
            console.log(bn.label);
            if (bn.label === "Next") {
                bn.disabled = this.page === this.totalPage ? true : false;
            }
            else if (bn.label === "Previous") {
                bn.disabled = this.page === 1 ? true : false;
            }
        });
    }

    fireToastEvent(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            default:
        }
    }

    deleteRow(row) {
        console.log('Inside deleteRow - Row Id : '+row.Id);
        deleteRecord(row.Id)
        .then(() => {
            this.fireToastEvent('Success!', 'Record deleted successfully', 'success', 'sticky');
            this.handleDataTable();
        })
        .catch(error => {
            this.fireToastEvent(this.label.errorMsg, error.body.message, 'error', 'sticky');
        });
    }
}