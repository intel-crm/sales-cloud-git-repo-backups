import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFIQuoteLineToApproveReject from '@salesforce/apex/Pricing_BulkSalesRepActionController.getFIQuoteLineToApproveReject';
import bulkApprovalRejectionQuoteLineRPM from '@salesforce/apex/Pricing_BulkSalesRepActionController.bulkApprovalRejectionQuoteLineRPM';
import noQLIforActionError from '@salesforce/label/c.Pricing_Tender_NoQuoteLinesForApprovals';
import nonLatinCharacters from '@salesforce/label/c.Pricing_Non_Latin_Char_Validation_Error';
import commentRegex from '@salesforce/label/c.Pricing_Latin_Characters_Regular_Expr_Label';
import Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview from '@salesforce/label/c.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview';
import getRejectionReasonsValue from '@salesforce/apex/Pricing_QuoteLineController.getRejectionReasonsValue';
import FIQuoteType from '@salesforce/label/c.Pricing_Tender_FinancialIncentive_Quote';
import rejectionReasonError from '@salesforce/label/c.Pricing_Tender_Rejection_Reason_Error';
import rejectionError from '@salesforce/label/c.Pricing_Tender_Rejection_Error';
import Pricing_rejection_reason_other_value from '@salesforce/label/c.Pricing_rejection_reason_other_value';
import getFIPricingManagerSearch from '@salesforce/apex/Pricing_BulkSalesRepActionController.getFIPricingManagerSearch';
import Pricing_FI_ApproveReject_PageSize from '@salesforce/label/c.Pricing_FI_ApproveReject_PageSize';

const pageNumberConst = 1;
const showIt = 'visibility:visible';
const hideIt = 'visibility:hidden';
export default class Pricing_FI_QuoteLine_BulkApproveReject extends LightningElement {

    @api recordId;
    @track quoteLineData = [];
    @track quoteLineDataToDisaplay = [];
    @track error = '';
    @track selectedData = [];

    openBulkApproveModal = false;
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

    @track today;
    @track displayData;
    @track recordPerPageCount = 0;

    @track showPagination; //Show/hide pagination; valid values are true/false
    @track pageSizeOptions = [Pricing_FI_ApproveReject_PageSize]; //[5, 10, 15]; 
    @track totalRecords; //Total no.of records; valid type is Integer
    @track pageSize; //No.of records to be displayed per page
    @track totalPages; //Total no.of pages
    @track pageNumber = pageNumberConst; //Page number
    @track controlPagination = showIt;
    @track controlPrevious = hideIt; //Controls the visibility of Previous page button
    @track controlNext = showIt; //Controls the visibility of Next page button

    @track quoteLineDataHasError = false;

    connectedCallback() {
        this.today = this.getTodaysDate();
    }

    getTodaysDate() {
        let today = new Date();
        let dd = today.getDate();
        let mm = today.getMonth() + 1; //January is 0!
        if (dd < 10) {
            dd = '0' + dd
        }
        if (mm < 10) {
            mm = '0' + mm
        }
        return today.getFullYear() + '-' + mm + '-' + dd;
    }

    openApproveDataTable() {
        this.openBulkApproveModal = true;
        this.openBulkRejectModal = false;
        this.getQuoteLines();
    }

    openRejectDataTable() {
        this.openBulkRejectModal = true;
        this.openBulkApproveModal = false;
        this.getQuoteLines();
    }

    getQuoteLines() {
        this.isSpinner = true;
        this.noRecords = false;
        this.quoteLineData = [];
        this.quoteLineDataToDisaplay = [];
        this.selectedData = [];
        getFIQuoteLineToApproveReject({ recordId: this.recordId })
            .then(result => {
                if (result.length == 0) {
                    this.noRecords = true;
                    this.msg = noQLIforActionError.replace('Field Review', 'Pricing Review');
                } else {
                    // Filter All QuoteLines Having Status Pricing Review.
                    this.quoteLineData = result.filter(item => item.Pricing_Status_Nm__c == Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview);

                    if (this.quoteLineData.length == 0) {
                        this.noRecords = true;
                        this.msg = noQLIforActionError.replace('Field Review', 'Pricing Review');
                    }
                }

                if (this.openBulkApproveModal) {
                    for (let i = 0; i < this.quoteLineData.length; i++) {
                        this.quoteLineData[i]["isSelected"] = false;
                        this.quoteLineData[i]["isError"] = false;
                        this.quoteLineData[i]["errorMsg"] = '';
                        this.quoteLineData[i]["partnerType"] = '';
                        this.quoteLineData[i].Pricing_Product_Nm__r.Name = this.quoteLineData[i].hasOwnProperty('Pricing_Product_Nm__r') ? this.getValueFix(this.quoteLineData[i].Pricing_Product_Nm__r.Name) : '';
                        this.quoteLineData[i]["searchKey"] = '';
                        this.quoteLineData[i]["CompetetorProduct"] = this.quoteLineData[i].hasOwnProperty('Pricing_Other_Competitor_Product_Nm__c') && (this.quoteLineData[i].Pricing_Other_Competitor_Product_Nm__c != null || this.quoteLineData[i].Pricing_Other_Competitor_Product_Nm__c != '' || this.quoteLineData[i].Pricing_Other_Competitor_Product_Nm__c != undefined)
                            ? this.quoteLineData[i].Pricing_Other_Competitor_Product_Nm__c
                            : this.quoteLineData[i].hasOwnProperty('Pricing_Competetor_Product__r') ? this.quoteLineData[i].Pricing_Competetor_Product__r.Name : '';

                        this.quoteLineData[i]["partnerType"] = this.quoteLineData[i].hasOwnProperty('SBQQ__Quote__r') ? this.quoteLineData[i].SBQQ__Quote__r.hasOwnProperty('Pricing_FI_Partner_Type__c') ? this.getValueFix(this.quoteLineData[i].SBQQ__Quote__r.Pricing_FI_Partner_Type__c) : '' : '';
                        this.quoteLineData[i].Pricing_SIPP_Cb__c = this.quoteLineData[i].hasOwnProperty('Pricing_SIPP_Cb__c') ? this.getValueFix(this.quoteLineData[i].Pricing_SIPP_Cb__c) : '';
                        this.quoteLineData[i].Pricing_Product_VerticalSegment__c = this.quoteLineData[i].hasOwnProperty('Pricing_Product_VerticalSegment__c') ? this.getValueFix(this.quoteLineData[i].Pricing_Product_VerticalSegment__c) : '';
                        this.quoteLineData[i].Pricing_FI_Net_RPU_Amt__c = this.quoteLineData[i].hasOwnProperty('Pricing_FI_Net_RPU_Amt__c') ? this.getValueFix(this.quoteLineData[i].Pricing_FI_Net_RPU_Amt__c) : '';
                        this.quoteLineData[i].Pricing_Approved_Unit_Qty__c = this.quoteLineData[i].hasOwnProperty('Pricing_Approved_Unit_Qty__c') ? this.getValueFix(this.quoteLineData[i].Pricing_Approved_Unit_Qty__c) : '';
                        this.quoteLineData[i].Pricing_Approved_Start_Date_Dt__c = this.quoteLineData[i].hasOwnProperty('Pricing_Approved_Start_Date_Dt__c') ? this.getValueFix(this.quoteLineData[i].Pricing_Approved_Start_Date_Dt__c) : '';
                        this.quoteLineData[i].Pricing_Approved_End_Date_Dt__c = this.quoteLineData[i].hasOwnProperty('Pricing_Approved_End_Date_Dt__c') ? this.getValueFix(this.quoteLineData[i].Pricing_Approved_End_Date_Dt__c) : '';
                        this.quoteLineData[i].Pricing_Additional_Comments_Txt__c = this.quoteLineData[i].hasOwnProperty('Pricing_Additional_Comments_Txt__c') ? this.getValueFix(this.quoteLineData[i].Pricing_Additional_Comments_Txt__c) : '';
                        this.quoteLineData[i].Pricing_Additional_T_C_s_Txt__c = this.quoteLineData[i].hasOwnProperty('Pricing_Additional_T_C_s_Txt__c') ? this.getValueFix(this.quoteLineData[i].Pricing_Additional_T_C_s_Txt__c) : '';
                        this.quoteLineData[i].Pricing_pm_approval_comments_nm__c = this.quoteLineData[i].hasOwnProperty('Pricing_pm_approval_comments_nm__c') ? this.getValueFix(this.quoteLineData[i].Pricing_pm_approval_comments_nm__c) : '';
                        this.quoteLineData[i].Pricing_Rejection_Comments_nm__c = this.quoteLineData[i].hasOwnProperty('Pricing_Rejection_Comments_nm__c') ? this.getValueFix(this.quoteLineData[i].Pricing_Rejection_Comments_nm__c) : '';
                        this.quoteLineData[i]["pricingManager"] = this.quoteLineData[i].hasOwnProperty('Pricing_Manager__r') ? this.quoteLineData[i].Pricing_Manager__r.Name : '';
                    }

                } else {
                    for (let i = 0; i < this.quoteLineData.length; i++) {
                        this.quoteLineData[i]["isSelected"] = false;
                        this.quoteLineData[i]["isError"] = false;
                        this.quoteLineData[i]["errorMsg"] = '';
                        this.quoteLineData[i]["partnerType"] = '';
                        this.quoteLineData[i].Pricing_Product_Nm__r.Name = this.quoteLineData[i].hasOwnProperty('Pricing_Product_Nm__r') ? this.getValueFix(this.quoteLineData[i].Pricing_Product_Nm__r.Name) : '';
                        this.quoteLineData[i].Pricing_Rejection_Reason__c = this.quoteLineData[i].hasOwnProperty('Pricing_Rejection_Reason__c') ? this.getValueFix(this.quoteLineData[i].Pricing_Rejection_Reason__c) : '';
                    }
                }
            })
            .then(_ => {
                this.totalRecords = this.quoteLineData.length;
                if (this.pageSizeOptions[0] > 0) {
                    this.pageSize = this.pageSizeOptions[0];
                    this.showPagination = true;
                }
                this.controlPagination = this.showPagination === false ? hideIt : showIt;
                this.setquoteLineDataToDisaplay();

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
                console.error('Error at getFIQuoteLineToApproveReject ' + JSON.stringify(error));
                this.isSpinner = false;
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
                    let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === selectedRows[i].dataset.id);
                    element.isSelected = event.target.checked;
                    this.getCopyToQuoteLineData(selectedRows[i].dataset.id, event.target.checked, 'isSelected');
                    this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
                }
            }
        }
        this.disabledBtn = this.quoteLineData.find(ele => ele.isSelected == true) ? false : true;
        this.openBulkApproveModal ? this.handleApprovalValidation() : this.handleRejectionValidation();
    }

    handleCheckBox(event) {
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        element.isSelected = event.target.checked;
        this.getCopyToQuoteLineData(event.target.dataset.id, event.target.checked, 'isSelected');
        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
        let allSelect = this.template.querySelector(`[data-id="selectAllCheckBox"]`);
        allSelect.checked = this.quoteLineDataToDisaplay.find(ele => ele.isSelected == false) ? false : true;
        this.openBulkApproveModal ? this.handleApprovalValidation() : this.handleRejectionValidation();
        this.disabledBtn = this.quoteLineData.find(ele => ele.isSelected == true) ? false : true;
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

    closeModal() {

        this.openBulkApproveModal = false;
        this.openBulkRejectModal = false;
        this.quoteLineData = [];
        this.quoteLineDataToDisaplay = [];
        this.error = '';
        this.selectedData = [];
        this.disabledBtn = true;
        this.pageNumber = 1;
        this.displayData = false;
        this.totalRecords = 0;
        this.pageSize = 0;
        this.totalPages = 0;
        this.recordPerPageCount = 0;
        eval('$A.get(\'e.force:refreshView\').fire();');
    }

    handleApprovedStartDate(event) {
        // on Change of Pricing_Approved_Start_Date_Dt__c
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Approved_Start_Date_Dt__c = event.target.value;
        this.getCopyToQuoteLineData(event.target.dataset.id, event.target.value, 'Pricing_Approved_Start_Date_Dt__c');
        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
        this.handleApprovalValidation();
    }

    removeRecordOnLookup(event) {
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        element.searchKey = '';
        element.recordsList = null;
        element.Pricing_Manager__c = null;
        element.Pricing_Manager__r = {};
        element.pricingManager = '';
        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
    }

    onLeave(event) {
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        setTimeout(() => {
            element.searchKey = '';
            element.recordsList = null;
        }, 300);
        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
    }

    handleKeyChange(event) {
        clearTimeout(this.typingTimer);
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        element.searchKey = event.target.value;
        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
        const thisKey = this;
        this.typingTimer = setTimeout(function () {
            thisKey.getLookupResult(element.Id);
        }.bind(this), 1000);
    }

    handleKeyDown() {
        clearTimeout(this.typingTimer);
    }

    getLookupResult(id) {
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === id);
        if (element.searchKey != null && element.searchKey != '' && element.searchKey != undefined) {
            getFIPricingManagerSearch({ searchKey: element.searchKey })
                .then((result) => {
                    if (result.length == 0 || result == '') {
                        element.recordsList = [];
                        element.message = 'No Records Found';
                        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
                    } else {
                        element.recordsList = result;
                        element.message = '';
                    }
                    this.error = null;
                })
                .catch((error) => {
                    this.error = error;
                    console.error('Error @ getFIPricingManagerSearch ' + JSON.stringify(error));
                    element.recordsList = null;
                });
        }
    }

    onRecordSelection(event) {
        if (this.pricingManagerQLineId != '') {
            let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === this.pricingManagerQLineId);
            element["Pricing_Manager__c"] = event.target.dataset.key;
            element["Pricing_Manager__r"] = {
                Id: event.target.dataset.key,
                Name: event.target.dataset.name
            };
            element.pricingManager = event.target.dataset.name;
            this.getCopyToQuoteLineData(this.pricingManagerQLineId, element["Pricing_Manager__r"], 'Pricing_Manager__r');
            this.getCopyToQuoteLineData(this.pricingManagerQLineId, event.target.dataset.key, 'Pricing_Manager__c');
            this.getCopyToQuoteLineData(this.pricingManagerQLineId, event.target.dataset.name, 'pricingManager');
            this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
        }
    }

    onfocusPricingmanager(event) {
        this.pricingManagerQLineId = event.target.dataset.id;
    }

    handleApprovedEndDate(event) {
        // on Change of Pricing_Approved_End_Date_Dt__c
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Approved_End_Date_Dt__c = event.target.value;
        this.getCopyToQuoteLineData(event.target.dataset.id, event.target.value, 'Pricing_Approved_End_Date_Dt__c');
        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
        this.handleApprovalValidation();
    }

    handleApprovedQuantity(event) {
        // on Change of Pricing_Approved_Unit_Qty__c
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Approved_Unit_Qty__c = event.target.value;
        this.getCopyToQuoteLineData(event.target.dataset.id, event.target.value, 'Pricing_Approved_Unit_Qty__c');
        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
        this.handleApprovalValidation();
    }

    handleRebatePerUnit(event) {
        event.preventDefault();
        // on Change of Pricing_FI_Net_RPU_Amt__c
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_FI_Net_RPU_Amt__c = event.detail.value;
        this.getCopyToQuoteLineData(event.target.dataset.id, event.target.value, 'Pricing_FI_Net_RPU_Amt__c');
        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
        this.handleApprovalValidation();
    }

    onFocusOutRebate(event) {
        event.preventDefault();
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        if (element.Pricing_FI_Net_RPU_Amt__c.toString().includes('.')) {
            element.Pricing_FI_Net_RPU_Amt__c = Math.round(element.Pricing_FI_Net_RPU_Amt__c * 100) / 100;
        }
        this.getCopyToQuoteLineData(event.target.dataset.id, element.Pricing_FI_Net_RPU_Amt__c, 'Pricing_FI_Net_RPU_Amt__c');
        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
    }

    handleQuantity(event) {
        // on Change of Pricing_Total_Volume_Qty__c
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Total_Volume_Qty__c = event.target.value;
        this.getCopyToQuoteLineData(event.target.dataset.id, event.target.value, 'Pricing_Total_Volume_Qty__c');
        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
        this.handleApprovalValidation();
    }

    handleAdditionalTnC(event) {
        // on Change of Pricing_Additional_T_C_s_Txt__c
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Additional_T_C_s_Txt__c = event.target.value;
        this.getCopyToQuoteLineData(event.target.dataset.id, event.target.value, 'Pricing_Additional_T_C_s_Txt__c');
        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
        this.handleApprovalValidation();
    }

    handleAdditionalComments(event) {
        // on Change of Pricing_Additional_Comments_Txt__c
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Additional_Comments_Txt__c = event.target.value;
        this.getCopyToQuoteLineData(event.target.dataset.id, event.target.value, 'Pricing_Additional_Comments_Txt__c');
        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
        this.handleApprovalValidation();
    }

    handleApproveComments(event) {
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_pm_approval_comments_nm__c = event.target.value;
            this.getCopyToQuoteLineData(event.target.dataset.id, event.target.value, 'Pricing_pm_approval_comments_nm__c');
            this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
            this.handleApprovalValidation();
      
    }

    handleRejectComments(event) {
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);     
            element.Pricing_Rejection_Comments_nm__c = event.target.value;
            this.getCopyToQuoteLineData(event.target.dataset.id, event.target.value, 'Pricing_Rejection_Comments_nm__c');
            this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
            this.handleRejectionValidation();
    }

    getCopyToQuoteLineData(id, data, field) { // keep Copy of eldited field in main JSON
        this.quoteLineData.forEach(element => {
            if (element.Id == id) {
                element[field] = JSON.parse(JSON.stringify(data));
            }
        });
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
        let element = this.quoteLineDataToDisaplay.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Rejection_Reason__c = event.target.value;
        this.getCopyToQuoteLineData(event.target.dataset.id, event.target.value, 'Pricing_Rejection_Reason__c');
        this.quoteLineDataToDisaplay = [...this.quoteLineDataToDisaplay];
        this.handleRejectionValidation();
    }

    handleApprovalValidation() {
        this.error = '';
        this.quoteLineDataToDisaplay.forEach(qli => {
            qli.errorMsg = '';
            qli.isError = false;
        });

        for (let i in this.quoteLineDataToDisaplay) {
            if (this.quoteLineDataToDisaplay[i].isSelected == true) {
                let flag = 0;

                if ((!this.quoteLineDataToDisaplay[i].Pricing_Additional_T_C_s_Txt__c == null || !this.quoteLineDataToDisaplay[i].Pricing_Additional_T_C_s_Txt__c == undefined || !this.quoteLineDataToDisaplay[i].Pricing_Additional_T_C_s_Txt__c == '') && !this.quoteLineDataToDisaplay[i].Pricing_Additional_T_C_s_Txt__c.match(commentRegex)) {
                    this.error = this.quoteLineDataToDisaplay[i].errorMsg += nonLatinCharacters + ' ';
                    this.quoteLineDataToDisaplay[i].isError = true;
                }

                if ((!this.quoteLineDataToDisaplay[i].Pricing_pm_approval_comments_nm__c == null || !this.quoteLineDataToDisaplay[i].Pricing_pm_approval_comments_nm__c == undefined || !this.quoteLineDataToDisaplay[i].Pricing_pm_approval_comments_nm__c == '') && !this.quoteLineDataToDisaplay[i].Pricing_pm_approval_comments_nm__c.match(commentRegex)) {
                    this.error = this.quoteLineDataToDisaplay[i].errorMsg += nonLatinCharacters + ' ';
                    this.quoteLineDataToDisaplay[i].isError = true;
                }

                if ((!this.quoteLineDataToDisaplay[i].Pricing_Additional_Comments_Txt__c == null || !this.quoteLineDataToDisaplay[i].Pricing_Additional_Comments_Txt__c == undefined || !this.quoteLineDataToDisaplay[i].Pricing_Additional_Comments_Txt__c == '') && !this.quoteLineDataToDisaplay[i].Pricing_Additional_Comments_Txt__c.match(commentRegex)) {
                    this.error = this.quoteLineDataToDisaplay[i].errorMsg += nonLatinCharacters + ' ';
                    this.quoteLineDataToDisaplay[i].isError = true;
                }

                if ((this.quoteLineDataToDisaplay[i].Pricing_Approved_Start_Date_Dt__c == null || this.quoteLineDataToDisaplay[i].Pricing_Approved_Start_Date_Dt__c == undefined || this.quoteLineDataToDisaplay[i].Pricing_Approved_Start_Date_Dt__c == '')) {
                    this.error = this.quoteLineDataToDisaplay[i].errorMsg += 'Approved Pricing Start Date, ';
                    flag++;
                    this.quoteLineDataToDisaplay[i].isError = true;
                }

                if ((this.quoteLineDataToDisaplay[i].Pricing_Approved_End_Date_Dt__c == null || this.quoteLineDataToDisaplay[i].Pricing_Approved_End_Date_Dt__c == undefined || this.quoteLineDataToDisaplay[i].Pricing_Approved_End_Date_Dt__c == '')) {
                    this.error = this.quoteLineDataToDisaplay[i].errorMsg += 'Approved Pricing End Date, ';
                    flag++;
                    this.quoteLineDataToDisaplay[i].isError = true;
                }

                if ((this.quoteLineDataToDisaplay[i].Pricing_Approved_Unit_Qty__c == null || this.quoteLineDataToDisaplay[i].Pricing_Approved_Unit_Qty__c == undefined || this.quoteLineDataToDisaplay[i].Pricing_Approved_Unit_Qty__c == '' || this.quoteLineDataToDisaplay[i].Pricing_Approved_Unit_Qty__c == 0)) {
                    this.error = this.quoteLineDataToDisaplay[i].errorMsg += 'Approved Quantity ';
                    flag++;
                    this.quoteLineDataToDisaplay[i].isError = true;
                }

                if (flag > 0) {
                    let verb = flag > 1 ? 'are ' : 'is ';
                    this.error = this.quoteLineDataToDisaplay[i].errorMsg = this.error = this.quoteLineDataToDisaplay[i].errorMsg + verb + 'required before quote line can be approved. Please ensure each field has a value and then try to approve the quote line again.  ';
                    this.quoteLineDataToDisaplay[i].isError = true;
                }

                if (this.quoteLineDataToDisaplay[i].Pricing_Approved_End_Date_Dt__c <= this.quoteLineDataToDisaplay[i].Pricing_Approved_Start_Date_Dt__c) {
                    this.error = this.quoteLineDataToDisaplay[i].errorMsg += 'Approved Pricing End Date cannot be earlier than Approved Pricing Start Date nor earlier than today. ';
                    this.quoteLineDataToDisaplay[i].isError = true;
                }

                if (this.quoteLineDataToDisaplay[i].Pricing_Approved_End_Date_Dt__c <= this.today) {
                    this.error = this.quoteLineDataToDisaplay[i].errorMsg += 'Approved Pricing End Date has already passed. Please enter Approved Pricing End Date in the future. ';
                    this.quoteLineDataToDisaplay[i].isError = true;
                }

                if (this.quoteLineDataToDisaplay[i].Pricing_FI_Net_RPU_Amt__c <= 0) {
                    this.quoteLineDataToDisaplay[i].isError = true;
                    this.error = this.quoteLineDataToDisaplay[i].errorMsg += 'Rebate Per Unit must be greater than 0. ';
                }

                if (this.quoteLineDataToDisaplay[i].Pricing_Approved_Unit_Qty__c <= 0) {
                    this.quoteLineDataToDisaplay[i].isError = true;
                    this.error = this.quoteLineDataToDisaplay[i].errorMsg += 'Approved Quantity must be greater than 0. ';
                }



                this.getCopyToQuoteLineData(this.quoteLineDataToDisaplay[i].Id, this.quoteLineDataToDisaplay[i].isError, 'isError');
                this.getCopyToQuoteLineData(this.quoteLineDataToDisaplay[i].Id, this.quoteLineDataToDisaplay[i].errorMsg, 'errorMsg');
            }
        }

    }

    handleRejectionValidation() {
        this.error = '';
        this.quoteLineDataToDisaplay.forEach(qli => {
            qli.errorMsg = '';
            qli.isError = false;
        });
        for (let i in this.quoteLineDataToDisaplay) {
            if (this.quoteLineDataToDisaplay[i].isSelected == true) {

                if ((!this.quoteLineDataToDisaplay[i].Pricing_Rejection_Comments_nm__c == null || !this.quoteLineDataToDisaplay[i].Pricing_Rejection_Comments_nm__c == undefined || !this.quoteLineDataToDisaplay[i].Pricing_Rejection_Comments_nm__c == '') && !this.quoteLineDataToDisaplay[i].Pricing_Rejection_Comments_nm__c.match(commentRegex)) {
                    this.error = this.quoteLineDataToDisaplay[i].errorMsg = nonLatinCharacters + ' ';
                    this.quoteLineDataToDisaplay[i].isError = true;
                }

                if (this.quoteLineDataToDisaplay[i].Pricing_Rejection_Reason__c == '' || this.quoteLineDataToDisaplay[i].Pricing_Rejection_Reason__c == undefined || this.quoteLineDataToDisaplay[i].Pricing_Rejection_Reason__c == null) {

                    this.error = this.quoteLineDataToDisaplay[i].errorMsg += rejectionReasonError;
                    this.quoteLineDataToDisaplay[i].isError = true;
                }

                if (this.quoteLineDataToDisaplay[i].Pricing_Rejection_Reason__c == Pricing_rejection_reason_other_value && (this.quoteLineDataToDisaplay[i].Pricing_Rejection_Comments_nm__c == '' || this.quoteLineDataToDisaplay[i].Pricing_Rejection_Comments_nm__c == null || this.quoteLineDataToDisaplay[i].Pricing_Rejection_Comments_nm__c == undefined)) {
                    this.error = this.quoteLineDataToDisaplay[i].errorMsg += rejectionError.replace('Approval/Rejection', 'Rejection');
                    this.quoteLineDataToDisaplay[i].isError = true;

                }

                this.getCopyToQuoteLineData(this.quoteLineDataToDisaplay[i].Id, this.quoteLineDataToDisaplay[i].isError, 'isError');
                this.getCopyToQuoteLineData(this.quoteLineDataToDisaplay[i].Id, this.quoteLineDataToDisaplay[i].errorMsg, 'errorMsg');

            }
        }
    }

    async handleAction(event) {
        this.selectedData = [];
        let action = event.currentTarget.dataset.name;
        this.isSpinner = true;
        action == 'Approved' ? this.handleApprovalValidation() : this.handleRejectionValidation();
        this.quoteLineDataHasError = false;
        for (let index = 0; index < this.quoteLineData.length; index++) {
            if (this.quoteLineData[index].isSelected == true && this.quoteLineData[index].isError == true) {
                this.quoteLineDataHasError = true;
            }
            if (this.quoteLineData[index].isSelected == true && this.quoteLineData[index].isError == false) {
                this.selectedData.push(JSON.parse(JSON.stringify(this.quoteLineData[index])));
            }
        }
        if (this.selectedData.length > 0 && this.error.length == 0 && !this.quoteLineDataHasError) {
            this.disabledBtn = true;
            this.selectedData.forEach(ql => {
                delete ql.isSelected;
                delete ql.Pricing_Quote_Line_Number__c;
                delete ql.errorMsg;
                delete ql.isError;
                ql.Pricing_Status_Nm__c = action;
            });
            await bulkApprovalRejectionQuoteLineRPM({ quoteLineData: this.selectedData, action: action, quoteType: FIQuoteType })
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
                        console.error('Error at bulkApprovalRejectionQuoteLineRPM ' + JSON.stringify(error));
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
            //this.disabledBtn = true;
        }
    }

    handlePageNumberChange(event) {
        this.pageNumber = event.target.value;
        this.setquoteLineDataToDisaplay();
    }

    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.setquoteLineDataToDisaplay();
        let allSelect = this.template.querySelector(`[data-id="selectAllCheckBox"]`);
        allSelect.checked = this.quoteLineDataToDisaplay.find(ele => ele.isSelected == false) ? false : true;
    }

    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.setquoteLineDataToDisaplay();
        let allSelect = this.template.querySelector(`[data-id="selectAllCheckBox"]`);
        allSelect.checked = this.quoteLineDataToDisaplay.find(ele => ele.isSelected == false) ? false : true;
    }

    setquoteLineDataToDisaplay() {
        this.quoteLineDataToDisaplay = [];

        if (this.pageSizeOptions[0] > this.totalRecords) {
            this.pageSize = this.totalRecords;
        }
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        this.setPaginationControls();

        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) break;
            this.quoteLineDataToDisaplay.push(JSON.parse(JSON.stringify(this.quoteLineData[i])));
        }
        this.recordPerPageCount = this.quoteLineDataToDisaplay.length;
        this.openBulkApproveModal ? this.handleApprovalValidation() : this.handleRejectionValidation();
        this.disabledBtn = this.quoteLineData.find(ele => ele.isSelected == true) ? false : true;
        this.displayData = true;
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
}