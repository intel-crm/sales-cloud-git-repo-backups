import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuoteLineDetails from '@salesforce/apex/Pricing_BulkSalesRepActionController.getQuoteLineDetails';
import getRejectionReasonsValue from '@salesforce/apex/Pricing_QuoteLineController.getRejectionReasonsValue';
import recordApproval from '@salesforce/apex/Pricing_BulkSalesRepActionController.recordApproval';
import rejectionError from '@salesforce/label/c.Pricing_Tender_Rejection_Error';
import noRecordMsg from '@salesforce/label/c.Pricing_Tender_NoQuoteLinesApprovalsAssigned';
import nonLatinCharacters from '@salesforce/label/c.Pricing_Non_Latin_Char_Validation_Error';
import commentRegex from '@salesforce/label/c.Pricing_Latin_Characters_Regular_Expr_Label';
import PendingIntelFieldReview from '@salesforce/label/c.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview';
import rejectionReasonError from '@salesforce/label/c.Pricing_Tender_Rejection_Reason_Error';
import Rejected from '@salesforce/label/c.Pricing_Tender_QuoteLine_Status_Rejected';
import revisionHelpText from '@salesforce/label/c.Pricing_IQR_RevisionHelpText';
import noQLIforActionError from '@salesforce/label/c.Pricing_Tender_NoQuoteLinesForApprovals';
import oemRevisionMsg from '@salesforce/label/c.Pricing_OEMRevision_Msg';
import oemRevisionnoChatterMsg from '@salesforce/label/c.Pricing_OEMRevision_noChatterMsg';
import noRecordRevisionMsg from '@salesforce/label/c.Pricing_BulkCustomerRevision_NoRecordMsg';
import Pricing_Write_In_Product from '@salesforce/label/c.Pricing_Write_In_Product';
import Pricing_rejection_reason_other_value from '@salesforce/label/c.Pricing_rejection_reason_other_value';
import ssdQuoteLine from '@salesforce/label/c.Pricing_Tender_SSD_Quote';
import stdQuoteLine from '@salesforce/label/c.Pricing_Tender_Standard_QuoteLine';
import svdQuoteLine from '@salesforce/label/c.Pricing_Tender_Small_Volume_Quote';
import nicQuoteLine from '@salesforce/label/c.Pricing_Tender_NIC_Quote';
import clientQuoteLine from '@salesforce/label/c.Pricing_Tender_CCG_Quote';
import Workload from "@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Workload_Nm__c";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import Quote_Line from "@salesforce/schema/SBQQ__QuoteLine__c";
import SoftWarningLabel from '@salesforce/label/c.Pricing_Tender_Soft_Warning_for_Large_Enterprise';
import { getRecord } from "lightning/uiRecordApi";
import QuoteType from "@salesforce/schema/SBQQ__Quote__c.Pricing_Program_Type_Nm__c";
import isActiveSVD from '@salesforce/apex/Pricing_QuoteLineController.getSVDQuoteActiveStatus';
const FIELDS = [QuoteType];

export default class Pricing_QuoteLine_BulkSalesRepAction extends LightningElement {

    @api recordId;
    @track data = [];
    @track dataToDisplay = [];
    @track error = '';
    @track selectedData = [];
    @api objectApiName;

    openModal = false;
    isSpinner = false;
    @track disabledBtn = true;

    mouseStart;
    oldWidth;

    @track noRecords = false;
    @track msg;

    @track picklistOptions = [];
    @track workloadpicklistOptions = [];
    @track showCommentField = false;
    @track revisionComments = '';
    @track commentLength = 0;
    helpText = revisionHelpText;
    @track isBulkCustomerRevision = false;
    @track headerTitle;
    @track issdmfastrack = false;
    @track isDataCenterCPU = false;
    @track isQUoteDataCenter = false;

    showSoftWarning = false;
    sftw_Action = '';
    @track softWarningLabel = SoftWarningLabel;
    isNON_SVDQuote = false;

    @wire(isActiveSVD, {})
    isSVDActive;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS, isSVDActive: '$isSVDActive' })
    wiredQuote({ error, data }) {
        if (error) {
            console.error('Error @ wiredQuote -->' + error.body.message);
        } else if (data) {
            this.isNON_SVDQuote = (data.fields.Pricing_Program_Type_Nm__c.value == svdQuoteLine && this.isSVDActive.data != undefined && this.isSVDActive.data) ? false : true;
        }
    }

    openDataTable(event) {
        this.openModal = true;
        this.isBulkCustomerRevision = event.target.dataset.name === 'bulkCustomerRevision' ? true : false;
        this.headerTitle = this.isBulkCustomerRevision ? 'Bulk Customer Revision' : 'Bulk Approve/Reject';
        this.getQuoteLines();
    }

    getQuoteLines() {
        this.isSpinner = true;
        this.noRecords = false;
        this.data = [];
        console.log('Fetching quote lines for recordId: ' + this.recordId);
        getQuoteLineDetails({ quoteId: this.recordId })
            .then(result => {
                if (result.length == 0) {
                    this.noRecords = true;
                    this.msg = !(this.isBulkCustomerRevision) ? noRecordMsg : noRecordRevisionMsg;
                } else {
                    this.data = !(this.isBulkCustomerRevision) ? result.filter(item => item.Pricing_Status_Nm__c == PendingIntelFieldReview) : result.filter(item => (item.Pricing_Status_Nm__c == PendingIntelFieldReview && item.Pricing_Change_Request_cb__c == false));

                    if (this.data.length == 0) {
                        this.noRecords = true;
                        this.msg = noQLIforActionError;
                    }
                }
                for (let i = 0; i < this.data.length; i++) {
                    this.data[i]["isSelected"] = false;
                    this.data[i].Pricing_Product_Nm__r.Name = this.data[i].Pricing_Product_Nm__r.Name == Pricing_Write_In_Product ? Pricing_Write_In_Product + ' (' + this.data[i].Pricing_Other_Product_Nm__c + ')' : this.data[i].Pricing_Product_Nm__r.Name;
                    this.data[i]["quantity"] = this.data[i].Pricing_Program_Type_Nm__c == ssdQuoteLine || this.data[i].Pricing_Program_Type_Nm__c == nicQuoteLine || this.data[i].Pricing_Program_Type_Nm__c == clientQuoteLine ? this.data[i].Pricing_Total_Volume_Qty__c : this.data[i].Pricing_Unit_Qty__c;
                    this.data[i]["approveRejectComments"] = '';
                    this.data[i]["isDataCenterCPU"] = this.data[i].Pricing_Program_Type_Nm__c == stdQuoteLine && this.data[i].Pricing_New_Change_Request_cb__c != true ? false : true;
                    this.data[i]["issdmfastrack"] = this.data[i].Pricing_Program_Type_Nm__c == clientQuoteLine || this.data[i].Pricing_Program_Type_Nm__c == stdQuoteLine ? true : false;
                }
            }).then(_ => {
                this.isSpinner = false;
            })
            .catch((error) => {
                console.error('Error at getQuoteLines: ' + error);
                this.error = error;

                const event = new ShowToastEvent({
                    title: 'Error',
                    message: this.error,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.isSpinner = false;
            });
    }

    handlePaginatorChange(event) {
        this.dataToDisplay = event.detail;
        this.isSpinner = false;
    }

    // allSelected(event) {
    //     let selectedRows = this.template.querySelectorAll('lightning-input');
    //     for (let i = 0; i < selectedRows.length; i++) {
    //         if (selectedRows[i].type === 'checkbox' && selectedRows[i].className.includes('checkBoxForUpdate')) {
    //             selectedRows[i].checked = event.target.checked;
    //             if (i > 0) {
    //                 let element = this.dataToDisplay.find(ele => ele.Id === selectedRows[i].dataset.id);
    //                 element.isSelected = event.target.checked;
    //                 this.dataToDisplay = [...this.dataToDisplay];
    //             }
    //         }
    //     }
    //     this.disabledBtn = this.dataToDisplay.find(ele => ele.isSelected == true) ? false : true;
    // }

    allSelected(event) {
        let selectedRows = this.template.querySelectorAll('lightning-input');
        let newDataToDisplay = [...this.dataToDisplay]; // Clone the data to avoid direct mutation

        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i].type === 'checkbox' && selectedRows[i].className.includes('checkBoxForUpdate')) {
                selectedRows[i].checked = event.target.checked;
                if (i > 0) {
                    // Find the index of the element in the array
                    let index = newDataToDisplay.findIndex(ele => ele.Id === selectedRows[i].dataset.id);
                    if (index !== -1) {
                        // Create a new object with updated isSelected
                        newDataToDisplay[index] = {
                            ...newDataToDisplay[index], // Copy existing properties
                            isSelected: event.target.checked // Update the property
                        };
                    }
                }
            }
        }
        this.dataToDisplay = newDataToDisplay; // Replace the reactive property with the updated array    
        // Update the button's disabled state based on selection
        this.disabledBtn = newDataToDisplay.some(ele => ele.isSelected === true) ? false : true;
    }


    handleCommentVisibility(event) {
        this.showCommentField = event.target.checked;
    }

    handleRevisionComments(event) {
        this.revisionComments = event.target.value;
        this.commentLength = 8000 - this.revisionComments.length;
    }

    calculateWidth(event) {
        let childObj = event.target;
        let parObj = childObj.parentNode;
        let count = 1;
        while (parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        let mouseStart1 = event.clientX;
        this.mouseStart = mouseStart1;
        this.oldWidth = parObj.offsetWidth;
    }

    setNewWidth(event) {
        let childObj = event.target;
        let parObj = childObj.parentNode;
        let count = 1;
        while (parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        let mouseStart1 = this.mouseStart;
        let oldWidth1 = this.oldWidth;
        let newWidth = event.clientX - parseFloat(mouseStart1) + parseFloat(oldWidth1);
        parObj.style.width = newWidth + 'px';
    }

    // handleCheckBox(event) {
    //     let element = this.dataToDisplay.find(ele => ele.Id === event.target.dataset.id);
    //     element.isSelected = event.target.checked;
    //     this.dataToDisplay = [...this.dataToDisplay];
    //     let allSelect = this.template.querySelector(`[data-id="selectAllCheckBox"]`);
    //     allSelect.checked = event.target.checked == false ? false : false;
    //     this.disabledBtn = this.dataToDisplay.find(ele => ele.isSelected == true) ? false : true;
    // }

    handleCheckBox(event) {
        const itemId = event.target.dataset.id; // Get the ID of the item being checked
        const newDataToDisplay = this.dataToDisplay.map(item => {
            if (item.Id === itemId) {
                return {
                    ...item, // Spread the existing properties
                    isSelected: event.target.checked // Update the isSelected property
                };
            }
            return item; // Return the item as is if it's not the one being updated
        });
    
        this.dataToDisplay = newDataToDisplay; // Update the reactive property
    
        // Update the "Select All" checkbox based on whether all rows are selected
        const allSelectCheckbox = this.template.querySelector(`[data-id="selectAllCheckBox"]`);
        const areAllChecked = newDataToDisplay.every(item => item.isSelected);
        allSelectCheckbox.checked = areAllChecked;
        // Enable or disable the button based on selection
        this.disabledBtn = this.dataToDisplay.find(ele => ele.isSelected == true) ? false : true;
    }
    closeModal() {
        this.openModal = false;
        this.data = [];
        this.dataToDisplay = [];
        this.error = '';
        this.selectedData = [];
        this.disabledBtn = true;
        this.showCommentField = false;
        //this.isBulkCustRevision = false;
        this.showSoftWarning = false;
        this.revisionComments = '';
        this.commentLength = 0;
        eval('$A.get(\'e.force:refreshView\').fire();');
    }

    handleRecommendedPriceChange(event) {
        // on Change of Pricing_FSE_Recommended_Price_Nm__c
        let element = this.dataToDisplay.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_FSE_Recommended_Price_Nm__c = event.target.value;
        this.dataToDisplay = [...this.dataToDisplay];
    }

    handleCommentChange(event) {
        // on Change of approveRejectComments
        let element = this.dataToDisplay.find(ele => ele.Id === event.target.dataset.id);
        element.approveRejectComments = event.target.value;
        this.dataToDisplay = [...this.dataToDisplay];
    }

    handleSdmFastTrackChange(event) {
        // on Change of SdmFastrack
        let element = this.dataToDisplay.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_SDM_Fast_Track__c = event.target.checked;
        this.dataToDisplay = [...this.dataToDisplay];
    }

    async handleAction(event) {
        let action = event.currentTarget.dataset.name;
        this.isSpinner = true;
        this.disabledBtn = true;
        this.selectedData = [];

        this.dataToDisplay.forEach(element => {
            if (element.isSelected) {
                delete element.Pricing_Product_Nm__c;
                delete element.SBQQ__Quote__c;
                if ((!element.approveRejectComments == '' || !element.approveRejectComments == undefined) && !element.approveRejectComments.match(commentRegex)) {
                    this.error = nonLatinCharacters;
                } else if (action == Rejected) {
                    if (element.Pricing_Rejection_Reason__c == '' || element.Pricing_Rejection_Reason__c == undefined || element.Pricing_Rejection_Reason__c == null) {
                        this.error = rejectionReasonError;
                    }
                    if (element.Pricing_Rejection_Reason__c == Pricing_rejection_reason_other_value && (element.approveRejectComments == '' || element.approveRejectComments == null || element.approveRejectComments == undefined)) {
                        this.error = rejectionError;
                    } else {
                        element.Pricing_Rejection_Comments_nm__c = element.approveRejectComments;
                    }
                } else if (action == 'Approved') {
                    element.Pricing_pm_approval_comments_nm__c = element.approveRejectComments;
                }
                this.selectedData.push(element);
            }
        });

        if (action == 'Approved' && (this.selectedData.length > 0) && (this.error.length === 0)) {
            this.selectedData.forEach(element => {
                if (element.isSelected && (element.Pricing_Program_Type_Nm__c == clientQuoteLine) && (element.Pricing_SIPP_Cb__c == false) && (element.hasOwnProperty('Pricing_Market_Segment_values_Nm__c')) && (element.Pricing_Market_Segment_values_Nm__c == "Corp") && (element.Pricing_Change_Request_cb__c == false)&&(element.Pricing_Form_Factor_Nm__c == "Notebook")) {
                    this.isSpinner = false;
                    this.showSoftWarning = true;
                    this.sftw_Action = action;
                }
            });
        }

        if (this.showSoftWarning == false && this.selectedData.length > 0 && this.error.length === 0) {
            await this.recordApprovalCall(action);
        } else if (this.error !== '') {
            const event = new ShowToastEvent({
                title: 'Error',
                message: this.error,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            this.disabledBtn = false;
            this.error = '';
            this.isSpinner = false;
        }
    }

    async recordApprovalCall(action) {
        this.isSpinner = true;
        await recordApproval({ quoteLineData: this.selectedData, action: action, revisionComments: this.revisionComments, isChatterTrue: this.showCommentField })
            .then(result => {
                if (result == 'Success' && action != 'Customer Revision') {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'Quote Lines ' + action + ' Successfully !',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }
                else if (result == 'Success' && action == 'Customer Revision') {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: this.showCommentField ? oemRevisionMsg : oemRevisionnoChatterMsg,
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }
            })
            .catch((error) => {
                console.error('Error at handleReject: ' + JSON.stringify(error));
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: JSON.stringify(error),
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            }).finally(_ => {
                this.isSpinner = false;
                this.closeModal();
            });
    }

    @wire(getObjectInfo, { objectApiName: Quote_Line })
    objectInfo;
    get recordTypeId() {
        // Returns a map of record type Ids
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find((rti) => rtis[rti].name === "Pricing_Tender_Quote_Line_Create");
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Workload })
    workloadpicklistvalue({ error, data }) {
        if (data) {
            data.values.forEach(element => {
                this.workloadpicklistOptions.push({ label: element.label, value: element.value });
            });
        } else if (error) {
            console.error('Error @ workloadpicklistvalue : ' + JSON.stringify(error));
        }
    }

    @wire(getRejectionReasonsValue, { recId: '$recordId' })
    rejectionReasonPicklistValue({ error, data }) {
        if (error) {
            const event = new ShowToastEvent({
                title: 'Error at getRejectionReasonsValue',
                message: JSON.stringify(error),
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            console.error('Error at getRejectionReasonsValue ' + JSON.stringify(error));
        } else if (data) {
            let value = Object.values(JSON.parse(JSON.stringify(data)));
            value.forEach(element => {
                this.picklistOptions.push({ label: element, value: element });
            });
        }
    }

    workloadChange(event) {
        let workloadelement = this.dataToDisplay.find(ele => ele.Id === event.target.dataset.id);
        workloadelement.Pricing_Workload_Nm__c = event.target.value;
        this.dataToDisplay = [...this.dataToDisplay];
    }

    rejectionReasonsChange(event) {
        let element = this.dataToDisplay.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Rejection_Reason__c = event.target.value;
        this.dataToDisplay = [...this.dataToDisplay];
    }

    handleContinueSoftWarning() {
        this.isSpinner = true;
        this.showSoftWarning = false;
        this.recordApprovalCall(this.sftw_Action);
    }

}