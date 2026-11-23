import { LightningElement, api, wire, track } from 'lwc';
import { getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLineItems from '@salesforce/apex/PCC_LineItemController.getLineItems';
import updateLineItemsStatus from '@salesforce/apex/PCC_LineItemController.updateLineItemsStatus';
import getColumns from '@salesforce/apex/PCC_LineItemController.getColumns';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import { getRecord } from "lightning/uiRecordApi";
import STATUS_FIELD from "@salesforce/schema/PCC_Deal_Change_Request__c.PCC_Approval_Status__c";
import { getRecordNotifyChange } from 'lightning/uiRecordApi';


const fields = [STATUS_FIELD];

export default class LineItemsList extends LightningElement {
    @api recordId;
    @api columnsConfig;
    @track lineItems = [];
    @track columns = [];
    @track wiredRecord;
    @track data = [];
    @track isModalOpen = false;
    @track selectedStatus;
    @track comments = '';
    @track selectedLineItemIds = [];
    @track showWarning = false;
    @track commentsError = false;
    @track isSpinner = false;
    
    wiredLineItemsResult;
    customColumns = [];
    @track showActions = false;
    draftValues = [];
    status;
    tableErrors = {};


    @wire(getRecord,
        {
            recordId: '$recordId',
            fields
        })
    changeRequest(result) {
        this.wiredRecord = result; // Store the result
        const { data, error } = result;
        if (data) {
            this.recordData = data;
            this.wiredRecord = result;
            this.status = getFieldValue(data, STATUS_FIELD);
            if (this.status === 'Review in Progress') {
                this.showActions = true;
            } else {
                this.showActions = false;
            }
            this.setEditable(this.lineItems);
            refreshApex(this.wiredRecord);
        }
    }
    /*get status() {
        return getFieldValue(this.changeRequest.data, STATUS_FIELD);
    }*/
    renderedCallback() {
        console.log('hello' + this.changeRequest.data);
        //  console.log('cas1',+getFieldValue(this.record.data, STATUS_FIELD));
    }


    @wire(getColumns)
    wiredColumns({ data, error }) {

        if (data) {
            data.map(col => {
                console.log(col);
                if (col.Enable_for_PSAM_Screen__c) {
                    this.customColumns.push(this.createColumns(col));
                }
            })
            this.columns = this.customColumns;
            console.log('Columns -->', this.columns);
        } else if (error) {
            console.error(error);
        }
    }


    connectedCallback() {
        // Listen for changes to the parent record's status
        getRecordNotifyChange([{ recordId: this.recordId }]);
        refreshApex(this.wiredRecord);
    }
    createColumns(col) {

        console.log('Create column for :', col);
        // console.log('JSON :', JSON.parse(col?.typeAttributes__c));
        return {

            label: col.Label__c,
            fieldName: col.WrapperFieldName__c,
            type: col.FieldType__c,
            editable: col.UseFieldName__c ? { fieldName: col.EditColumn__c } : col.EditDefaultValue__c,
            disabled: col.UseFieldName__c ? { fieldName: col.Disabled__c } : col.DisableDefaultValue__c,
            typeAttributes: col.typeAttributes__c != null ? JSON.parse(col.typeAttributes__c) : '',
            initialWidth: col.initialWidth__c,
            wrapText: col.wrapText__c,
            cellAttributes: col.cellAttributes__c != null ? JSON.parse(col.cellAttributes__c) : '',
        };

    }




    @wire(getLineItems, { parentId: '$recordId' })
    wiredLineItems(result) {
        this.wiredLineItemsResult = result;
        console.log('wiredLineItemsResult', result.data);
        console.log('wiredLineItemsResult', this.status);
        if (result.data) {
            this.lineItems = result.data.map(row => {
                // let newRow = {};
                // newRow = {...row};
                console.log("here", row);
                let statusClass1 = '';
                if (row.PCC_End_Date__c != null) {
                    statusClass1 = 'customHighlight';
                } else {
                    statusClass1 = 'customHighlight';
                }
               //
               if(row.PCC_Request_Type__c === 'Cancel' || row.PCC_Approval_Status__c !='Pending' || this.status != 'Review in Progress' ){
                return {...row, statusClass : statusClass1 ,change: false , View: 'View details'};
            } else {
                return {...row, statusClass : statusClass1,change: true, View: 'View details'};
            }
            });

            //  this.lineItems = result.data;
            this.lineItemsError = undefined;
          //  this.setEditable(result.data);
        } else if (result.error) {
            this.lineItems = [];
            this.lineItemsError = result.error;
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedLineItemIds = selectedRows.map(row => row.Id);
        this.showWarning = false;

    }

    handleApprove() {
        this.isSpinner = true;

        if (!this.hasPendingLineItems()) {
            this.showWarning = true;
            return;
        }
        /* this.selectedStatus = 'Approved- RPM Pending';
         this.isModalOpen = true;*/
        console.log('selected' + this.selectedLineItemIds);
        const today = this.getDate(new Date());
        let rowsError = {};


        this.selectedLineItemIds.forEach((draft) => {
            //draft.CancelProduct = false;
            let messages = [];
            let fieldNames = [];
            const record = this.lineItems.find(item => item.Id === draft);

            console.log('record -->', record);

            if (parseInt(record.PCC_Quantity__c) == parseInt(record.CoreApprovedQuantity)) {
                messages.push('New Quantity should not be same as Approved quantity');
                fieldNames.push('PCC_Quantity__c');
            }

            if (record.PCC_Start_Date__c != null && record.PCC_Start_Date__c === record.ApprovedPricingStartDate) {
                messages.push('The new pricing start date cannot be same as the approved pricing start date');
                fieldNames.push('PCC_Start_Date__c');
            }

            if (record.PCC_End_Date__c != null && record.PCC_End_Date__c === record.ApprovedPricingEndDate) {
                messages.push('The new pricing end date cannot be same as approved pricing end date');
                fieldNames.push('PCC_End_Date__c');
            }

            if (record.PCC_End_Date__c != null && record.PCC_Start_Date__c != null && record.PCC_End_Date__c <= record.PCC_Start_Date__c) {
                messages.push('Please enter the pricing end date greater than Pricing start date');
                fieldNames.push('PCC_End_Date__c');
            }
            if (record.PCC_Start_Date__c != null && record.PCC_End_Date__c != null && (record.PCC_Start_Date__c >= record.PCC_End_Date__c)) {
                messages.push('Please enter the Pricing start date lesser than Pricing end date.');
                fieldNames.push('PCC_Start_Date__c');
            }
            if (record.PCC_End_Date__c != null && record.PCC_End_Date__c <= record.ApprovedPricingStartDate) {
                messages.push('The new pricing end date should be greater than the approved pricing start date');
                fieldNames.push('PCC_End_Date__c');
            }
            if (record.PCC_End_Date__c != null && (record.PCC_End_Date__c <= today)) {
                messages.push('Please enter the pricing end date greater than today');
                fieldNames.push('PCC_End_Date__c');
            }

            // Populate errors
            if (messages.length > 0) {
                rowsError[draft] = {
                    title: `${messages.length} error(s) on this row`,
                    messages: messages,
                    fieldNames: fieldNames
                };



            } else {
                // Update the data array with the draft values if no errors

                console.log('index -->');
                /*this.cellEditCss(this.data, 'editRow');
                if (rIndex !== -1) {
                    console.log('you are here');
                    draft.isChanged = true;
                    this.data[rIndex] = { ...this.data[rIndex], ...draft };
                    console.log('data -->', this.data);
                    messages = [];
                    fieldNames = [];
                    rowsError = {};
                }*/

            }
        });

        if (Object.keys(rowsError).length === 0) {

            this.selectedStatus = 'Approved';

            this.isModalOpen = true;
        }
        else {
            this.tableErrors = {
                rows: rowsError,
                table: {
                    title: 'Your entry cannot be saved. Fix the errors and try again.',
                    messages: Object.keys(rowsError).length > 0 ? [`${Object.keys(rowsError).length} row/s has error(s). Navigate to the rows to see the issues.`] : []
                }
            };
        }
    }

    handleReject() {
      
        if (!this.hasPendingLineItems()) {
            this.showWarning = true;
            return;
        }
        this.selectedStatus = 'Rejected';
        this.isModalOpen = true;
    }
    hasPendingLineItems() {
        console.log('here' + this.lineItems.some(item => this.selectedLineItemIds.includes(item.Id) && item.Status__c === 'Pending'));
        console.log('Line Items:', this.lineItems);
        return this.lineItems.some(item => {
            const isSelected = this.selectedLineItemIds.includes(item.Id);
            const isPending = item.PCC_Approval_Status__c === 'Pending';
            console.log(`Item ID: ${item.Id}, Is Selected: ${isSelected}, Is Pending: ${isPending}`);
            return isSelected && isPending;
        });
    }

    handleCommentsChange(event) {
        this.comments = event.target.value;
        this.commentsError = false; // Reset comments error state on input
    }

    closeModal() {
        this.isModalOpen = false;
    }

    submitComments() {

        if (this.comments.trim() === '') {
            this.commentsError = true; // Set comments error state if comments are empty
            return;
        }
        else{
            this.isSpinner = true;
        }
        if (this.selectedLineItemIds.length === 0) {
            this.showToast('Error', 'No line items selected', 'error');
            return;
        }
        updateLineItemsStatus({
            lineItemIds: this.selectedLineItemIds,
            status: this.selectedStatus,
            comments: this.comments,
            recordId: this.recordId
        })
            .then(() => {
                if (this.selectedStatus === 'Approved- RPM Pending') {
                    this.selectedStatus = 'Approved';
                }
                this.isSpinner = false;
                this.showToast('Success', `Line items ${this.selectedStatus}`, 'success');
                this.comments = '';
                //this.refreshPage();
                this.dispatchEvent(new RefreshEvent());
                return refreshApex(this.wiredLineItemsResult);
                
            })
            .catch(error => {
                this.isSpinner = false;
                console.log('here'+JSON.stringify(error.body));
                let statusCode = error.body?.pageErrors?.[0]?.statusCode;
                if(statusCode && (statusCode.includes("ENTITY_IS_LOCKED") || statusCode.includes("INSUFFICIENT_ACCESS"))){
                    this.showToast('Error', 'You dont have neccessary permission to perform this action.', 'error');
                }
                else{
                    this.showToast('Error', 'There is an issue processing the record. Please raise a support ticket.', 'error');
                }
            });

        this.isModalOpen = false;
        this.selectedLineItemIds = '';

    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }

    get commentsErrorClass() {
        return this.commentsError ? 'slds-has-error' : '';
    }


    refreshPage() {
        fireEvent(this.pageRef, 'force:refreshView');
        refreshApex(this.recordId);
    }


    async handleSave(event) {
        // Convert datatable draft values into record objects
        this.tableErrors = [];
        const draftValuesList = event.detail.draftValues;
        const today = this.getDate(new Date());
        let rowsError = {};


        draftValuesList.forEach((draft) => {
            //draft.CancelProduct = false;
            let messages = [];
            let fieldNames = [];
            const rowIndex = draft.Id || draft.id;
            const recordId = rowIndex.includes('-') ? rowIndex.split('-')[1] : rowIndex;
            const record = this.lineItems.find(item => item.Id === recordId);

            // Validate CoreQLStartDt field
            //const record = this.lineItems[rIndex];
            console.log('record -->', record);
            //draft.CoreQLAdditionalCommentsTxt = draft.CoreQLAdditionalCommentsTxt ? draft.CoreQLAdditionalCommentsTxt : record.CoreQLAdditionalCommentsTxt

            if (parseInt(draft.PCC_Quantity__c) == parseInt(record.CoreApprovedQuantity)) {
                messages.push('New Quantity should not be same as Approved quantity');
                fieldNames.push('PCC_Quantity__c');
            }

            if (draft.PCC_Start_Date__c != null && draft.PCC_Start_Date__c === record.ApprovedPricingStartDate) {
                messages.push('The new pricing start date cannot be same as the approved pricing start date');
                fieldNames.push('PCC_Start_Date__c');
            }

            if (draft.PCC_End_Date__c != null && draft.PCC_End_Date__c === record.ApprovedPricingEndDate) {
                messages.push('The new pricing end date cannot be same as approved pricing end date');
                fieldNames.push('PCC_End_Date__c');
            }

            if (draft.PCC_End_Date__c != null && draft.PCC_End_Date__c <= record.ApprovedPricingStartDate) {
                messages.push('The new pricing end date should be greater than the approved pricing start date');
                fieldNames.push('PCC_End_Date__c');
            }

            /*if (draft.PCC_Start_Date__c != null && (draft.PCC_Start_Date__c <= today )) {
                messages.push('Please enter the Pricing start date greater than today.');
                fieldNames.push('PCC_Start_Date__c');
            }*/
            if (draft.PCC_Start_Date__c != null && draft.PCC_End_Date__c != null && draft.PCC_Start_Date__c >= draft.PCC_End_Date__c) {
                messages.push('Please enter the Pricing start date lesser than Pricing end date.');
                fieldNames.push('PCC_Start_Date__c');
            }
            if (draft.PCC_End_Date__c != null && (draft.PCC_End_Date__c <= today)) {
                messages.push('Please enter the pricing end date greater than today');
                fieldNames.push('PCC_End_Date__c');
            }
            if (draft.PCC_End_Date__c != null && draft.PCC_Start_Date__c != null && (draft.PCC_End_Date__c <= draft.PCC_Start_Date__c)) {
                messages.push('Please enter the Pricing end date greater than Pricing start date');
                fieldNames.push('PCC_End_Date__c');
            }

            // Populate errors
            if (messages.length > 0) {
                rowsError[rowIndex] = {
                    title: `${messages.length} error(s) on this row`,
                    messages: messages,
                    fieldNames: fieldNames
                };


            }
        });

        if (Object.keys(rowsError).length === 0) {
            // this.draftValues = [];
            this.tableErrors = {};
            const records = event.detail.draftValues.slice().map((draftValue) => {
                const fields = Object.assign({}, draftValue);
                return { fields };
            });

            // Clear all datatable draft values
            this.draftValues = [];

            try {
                const recordUpdatePromises = records.map((record) => updateRecord(record));
                await Promise.all(recordUpdatePromises);

                // Report success with a toast
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Line Items updated",
                        variant: "success",
                    }),
                );

                // Display fresh data in the datatable
                console.log('here', this.wiredLineItemsResult);

                await refreshApex(this.wiredLineItemsResult);
            } catch (error) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error updating Line Items",
                        message: error.body.message,
                        variant: "error",
                    }),
                );
            }

        } else {

            this.tableErrors = {
                rows: rowsError,
                table: {
                    title: 'Your entry cannot be saved. Fix the errors and try again.',
                    messages: Object.keys(rowsError).length > 0 ? [`${Object.keys(rowsError).length} row/s has error(s). Navigate to the rows to see the issues.`] : []
                }
            };
        }
        console.log('rowsError', this.tableErrors);

        // Clear draft values after processing

    }

    getDate(datetime) {
        const date = new Date(datetime);
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0'); // Months are zero-based
        const day = String(date.getDate()).padStart(2, '0');

        return `${year}-${month}-${day}`;
    }
    _showActions = false;
    get showActions() {
        return this._showActions;
    }


    // Custom setter for showActions
    set showActions(value) {
        if (this._showActions !== value) {
            this._showActions = value;
            // When showActions changes, refresh the datatable
            this.refreshDataTable();
        }
    }
    // Method to refresh the datatable
    refreshDataTable() {
        refreshApex(this.wiredRecord);
    }


    setEditable(data) {
        this.lineItems = data.map(row => {
            if (row.PCC_Request_Type__c === 'Cancel' || row.PCC_Approval_Status__c != 'Pending' || this.status != 'Review in Progress') {
                return { ...row, change: false };
            } else {
                return { ...row, change: true };
            }
        });
}
}