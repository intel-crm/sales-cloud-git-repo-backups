import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuoteLineToRejectByRPM from '@salesforce/apex/Pricing_BulkSalesRepActionController.getQuoteLineToRejectByRPM';
import bulkApprovalRejectionQuoteLineRPM from '@salesforce/apex/Pricing_BulkSalesRepActionController.bulkApprovalRejectionQuoteLineRPM';
import noQLIforActionError from '@salesforce/label/c.Pricing_Tender_NoQuoteLinesForApprovals';
import nonLatinCharacters from '@salesforce/label/c.Pricing_Non_Latin_Char_Validation_Error';
import commentRegex from '@salesforce/label/c.Pricing_Latin_Characters_Regular_Expr_Label';
import getRejectionReasonsValue from '@salesforce/apex/Pricing_QuoteLineController.getRejectionReasonsValue';
import rejectionReasonError from '@salesforce/label/c.Pricing_Tender_Rejection_Reason_Error';
import rejectionError from '@salesforce/label/c.Pricing_Tender_Rejection_Error';
import Pricing_rejection_reason_other_value from '@salesforce/label/c.Pricing_rejection_reason_other_value';

export default class PricingRPMBulkReject extends LightningElement {

    @api recordId;
    @track quoteLineData = [];
    @track error = '';
    @track selectedData = [];

    openBulkRejectModal = false;
    isSpinner = false;
    disabledBtn = true;

    mouseStart;
    oldWidth;
    noRecords = false;
    @track msg;
    @track picklistOptions = [];
    validation = false;
    @track pricingManagerQLineId = '';

    openRejectDataTable() {
        this.openBulkRejectModal = true;
        this.getQuoteLines();
    }

    getQuoteLines() {
        this.isSpinner = true;
        this.noRecords = false;
        this.quoteLineData = [];
        this.selectedData = [];
        getQuoteLineToRejectByRPM({ recordId: this.recordId })
            .then(result => {
                console.log('Calling Apex Method getQuoteLineToRejectByRPM', result);
                if (result.length == 0) {
                    this.noRecords = true;
                    this.msg = noQLIforActionError.replace('Field Review', 'Pricing Review');
                } else {
                    this.quoteLineData = result;
                                        if (this.quoteLineData.length == 0) {
                        this.noRecords = true;
                        this.msg = noQLIforActionError.replace('Field Review', 'Pricing Review');
                    }
                }

                for (let i = 0; i < this.quoteLineData.length; i++) {
                    this.quoteLineData[i]["isSelected"] = false;
                    this.quoteLineData[i]["isError"] = false;
                    this.quoteLineData[i]["errorMsg"] = '';
                    this.quoteLineData[i]["approveRejectComments"] = '';
                    this.quoteLineData[i]["partnerType"] = '';
                    this.quoteLineData[i].Pricing_Product_Nm__r.Name = this.quoteLineData[i].hasOwnProperty('Pricing_Product_Nm__r') ? this.getValueFix(this.quoteLineData[i].Pricing_Product_Nm__r.Name) : '';
                    this.quoteLineData[i].Pricing_Rejection_Reason__c = this.quoteLineData[i].hasOwnProperty('Pricing_Rejection_Reason__c') ? this.getValueFix(this.quoteLineData[i].Pricing_Rejection_Reason__c) : '';
                }
            })
            .then(_ => {
                this.isSpinner = false;
            })
            .catch((error) => {
                this.error = JSON.stringify(error);
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: this.error,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            });
    }

    getValueFix(val) {
        return val === '' || val === undefined || val === null ? '' : val;
    }

    allSelected(event) {
        let selectedRows = this.template.querySelectorAll('lightning-input');
        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i].type === 'checkbox' && selectedRows[i].className.includes('checkBoxForUpdate')) {
                selectedRows[i].checked = event.target.checked;
                if (i > 0) {
                    let element = this.quoteLineData.find(ele => ele.Id === selectedRows[i].dataset.id);
                    element.isSelected = event.target.checked;
                    this.quoteLineData = [...this.quoteLineData];
                }
            }
        }
        this.disabledBtn = this.quoteLineData.find(ele => ele.isSelected == true) ? false : true;
        this.handleRejectionValidation();
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

    handleCheckBox(event) {
        let element = this.quoteLineData.find(ele => ele.Id === event.target.dataset.id);
        element.isSelected = event.target.checked;
        this.quoteLineData = [...this.quoteLineData];
        let allSelect = this.template.querySelector(`[data-id="selectAllCheckBox"]`);
        allSelect.checked = event.target.checked == false ? false : false;
        this.disabledBtn = this.quoteLineData.find(ele => ele.isSelected == true) ? false : true;
        this.handleRejectionValidation();
    }

    closeModal() {
        this.openBulkRejectModal = false;
        this.quoteLineData = [];
        this.error = '';
        this.selectedData = [];
        this.disabledBtn = true;
        eval('$A.get(\'e.force:refreshView\').fire();');
    }

    handleApproveRejectComments(event) {
        let element = this.quoteLineData.find(ele => ele.Id === event.target.dataset.id);
        element.approveRejectComments = event.target.value;
        this.quoteLineData = [...this.quoteLineData];
        this.handleRejectionValidation();
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

    rejectionReasonsChange(event) {
        let element = this.quoteLineData.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Rejection_Reason__c = event.target.value;
        this.quoteLineData = [...this.quoteLineData];
        this.handleRejectionValidation();
    }

    handleRejectionValidation() {
        this.selectedData = [];
        this.error = '';
        this.quoteLineData.forEach(qli => {
            qli.errorMsg = '';
            qli.isError = false;
        });
        let errorCount = 0;
        for (let i in this.quoteLineData) {
            if (this.quoteLineData[i].isSelected == true) {
                let validation = false;

                if ((!this.quoteLineData[i].approveRejectComments == null || !this.quoteLineData[i].approveRejectComments == undefined || !this.quoteLineData[i].approveRejectComments == '') && !this.quoteLineData[i].approveRejectComments.match(commentRegex)) {
                    this.quoteLineData[i].errorMsg = nonLatinCharacters + ' ';
                    validation = true;
                }

                if (this.quoteLineData[i].Pricing_Rejection_Reason__c == '' || this.quoteLineData[i].Pricing_Rejection_Reason__c == undefined || this.quoteLineData[i].Pricing_Rejection_Reason__c == null) {
                    this.quoteLineData[i].isError = true;
                    this.quoteLineData[i].errorMsg += rejectionReasonError;
                    this.error = rejectionReasonError;
                    validation = true;
                }

                if (this.quoteLineData[i].Pricing_Rejection_Reason__c == Pricing_rejection_reason_other_value && (this.quoteLineData[i].approveRejectComments == '' || this.quoteLineData[i].approveRejectComments == null || this.quoteLineData[i].approveRejectComments == undefined)) {
                    this.quoteLineData[i].isError = true;
                    this.quoteLineData[i].errorMsg += rejectionError.replace('Approval/Rejection','Rejection');
                    this.error = rejectionError.replace('Approval/Rejection','Rejection');
                    validation = true;
                } else {
                    this.quoteLineData[i].Pricing_Rejection_Comments_nm__c = this.quoteLineData[i].approveRejectComments;
                }

                errorCount = validation ? errorCount + 1 : errorCount;
                this.quoteLineData[i].isError = validation;
                if (errorCount === 0) {
                    this.selectedData.push(this.quoteLineData[i]);
                }
            }
        }
    }

    async handleAction(event) {
        let action = event.currentTarget.dataset.name;
        this.isSpinner = true;
        this.handleRejectionValidation();

        if (this.selectedData.length > 0 && this.error.length === 0) {
            this.disabledBtn = true;
            this.selectedData.forEach(ql => {
                delete ql.isSelected;
                delete ql.Pricing_Quote_Line_Number__c;
                delete ql.errorMsg;
                delete ql.isError;
                ql.Pricing_Status_Nm__c = action;
            });

            await bulkApprovalRejectionQuoteLineRPM({ quoteLineData: this.selectedData, action: action , quoteType : 'Tenders'})
                .then(result => {
                    if (result == 'Success') {
                        const event = new ShowToastEvent({
                            title: 'Success',
                            message: 'Quote Lines ' + action + ' Successfully !',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                    } else {
                        this.error = result;
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: JSON.stringify(result),
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                    }
                })
                .catch((error) => {
                    console.error('Error @ bulkApprovalRejectionQuoteLineRPM ' + JSON.stringify(error));
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
        } else {
            const toastMessage = new ShowToastEvent({
                title: 'Error',
                message: 'Error has occurred while processing. Please hover over the error indicator for more detail',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(toastMessage);
            this.isSpinner = false;
        }
    }
}