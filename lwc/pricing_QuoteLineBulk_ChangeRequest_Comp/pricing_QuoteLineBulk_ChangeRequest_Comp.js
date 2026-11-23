import { LightningElement, track, api, wire } from 'lwc';
import getQuoteLineforTable from '@salesforce/apex/Pricing_QuoteLine_Bulk_CR_Controller.getQuoteLineDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateQuotelines from '@salesforce/apex/Pricing_QuoteLine_BulkDealController.updateQuoteLineDetails';
import getRestrictedAccount from '@salesforce/apex/Pricing_QuoteLineCloneController.restrictedAccountMethod';
import getPicklistBulkDealController from '@salesforce/apex/Pricing_QuoteLine_BulkDealController.getPicklistBulkDealController';
import findRecords from '@salesforce/apex/Pricing_QuoteLine_BulkDealController.findRecords';

//labels having error messages
import ccgQuoteLine from '@salesforce/label/c.Pricing_Tender_CCG_Quote';
import pmemQuoteLine from '@salesforce/label/c.Pricing_Tender_PMem_Quote';
import ssdQuoteLine from '@salesforce/label/c.Pricing_Tender_SSD_Quote';
import nicQuoteLine from '@salesforce/label/c.Pricing_Tender_NIC_Quote';
import mandatoryFields from '@salesforce/label/c.Pricing_Tender_MyDeal_Integration_Mandatory_Fields';
import pastDateError from '@salesforce/label/c.Pricing_Mydeal_End_Date_Past_Error';
import meetCompPriceError from '@salesforce/label/c.Pricing_Tender_CR_negativeMeetCompPricevalueError';
import billingStartDateError from '@salesforce/label/c.Pricing_Tender_QuoteLine_Billing_StartDate_Error';
import billingEndDateError from '@salesforce/label/c.Pricing_Tender_CR_billingApprovedDateError';
import billingDateError from '@salesforce/label/c.Pricing_Tender_CR_billingDateError';
import approvedQuantityError from '@salesforce/label/c.Pricing_Tender_CR_negativeApprovedQuatityvalueError';
import ecapPriceError from '@salesforce/label/c.Pricing_Tender_CR_negativeApprovedPricevalueError';
import endDateBeforeStartDate from '@salesforce/label/c.Pricing_Tender_CR_approvedEndDtBeforeApprovedStartDtError';
import billingQuarterError from '@salesforce/label/c.Pricing_Tender_QuoteLine_Billing_Quarter_Error';
import noOfDays from '@salesforce/label/c.Pricing_Days';
import bulkFields from '@salesforce/label/c.Pricing_BulkCR_Fields';
import toolTip from '@salesforce/label/c.Pricing_BulkUpdateDeal_helpText';
import latinCharCheck from '@salesforce/label/c.Pricing_Latin_Characters_Regular_Expr_Label';
import latinErrorMsg from '@salesforce/label/c.Pricing_Non_Latin_Char_Validation_Error';
import payableQtyEcxeedError from '@salesforce/label/c.Pricing_Tender_QuoteLine_Payable_Quantity_Error';
import meetCompAndEfftiveDtaeError from '@salesforce/label/c.Pricing_Tender_CR_MeetCompPriceandEffectiveStartDatevalueError';
import effectiveDateError from '@salesforce/label/c.Pricing_Tender_CR_effPricingStartDtOnChangeError';
import payableQtyEditError from '@salesforce/label/c.Pricing_PayableQty_NonRestrictEdit_Error';
import payableQtyEditWonQlError from '@salesforce/label/c.Pricing_PayableQty_Edit_Restric_Error';
import startDateEditError from '@salesforce/label/c.Pricing_StartDateEdit_Error';
import approvedEndDtPastError from '@salesforce/label/c.Pricing_Tender_CR_PricingApproveEndDtPastCheckError';
import effDateBlankError from '@salesforce/label/c.Pricing_QLI_EffectiveDateRequired_ErrorMsg';
import effDateApprovedQlEditError from '@salesforce/label/c.Pricing_EffectivePricingDate_ApprovedQLEdit_Error';
import effDatePastDealEditError from '@salesforce/label/c.Pricing_EffectivePricingDate_PastDealEdit_Error';
import ecapPricePastDealEditError from '@salesforce/label/c.Pricing_ApprovedEcapPrice_PastDealEdit_Error';
import qlApprovedStatus from '@salesforce/label/c.Pricing_Tender_QuoteLine_Status_Approved';
import qlWonStatus from '@salesforce/label/c.Pricing_Tender_QuoteLine_Status_Won';
import SoftWarningApprovedECAPLabel from '@salesforce/label/c.Pricing_Tender_Approved_ECAP';

export default class Pricing_QuoteLine_BulkCreateDeal extends LightningElement {
    @api recordId;
    @track dataTableColumns;
    @track openModal = false;
    @track errorMsg = '';
    @track data;
    @track action;
    @track isSpinner = false;
    @track errorList = [];

    @track options = [];
    @track requiredFields;
    @track errorString;
    @track oldWidth;
    @track mouseStart;
    @track isUpdateDeal = false;
    @track isSave = false;
    @track isNoData = false;
    msg;
    @track showBtn = false;
    @track bulkFieldstoDisplay;
    @track showLabel = false;
    @track date;
    label = {
        toolTip
    };

    @track selectedRecord;
    @track message;
    @track pricingManagerQLineId = '';
    typingTimer;
    @track accId;
    @track quoteRegion;
    @track quoteId;
    @track restrictedAcc = false;
    quoteLineFieldsMap = new Map([["Pricing_ECAP_Price_Amt__c", "Approved ECAP Price"],
        ["Pricing_Meet_Comp_Price_Amt__c", "My Deals Meet Comp Price"],
        ["Pricing_Approved_Start_Date_Dt__c", "Approved Pricing Start Date"],
        ["Pricing_Approved_End_Date_Dt__c", "Approved Pricing End Date"],
        ["Pricing_Approved_Unit_Qty__c", "Approved Quantity"],
        ["Pricing_Market_Segment_Nm__c", "Market Segment Type"],
        ["Pricing_Market_Segment_values_Nm__c", "Market Segment"],
        ["Pricing_Billing_End_Date_Dt__c", "Billing End Date (for consumption)"],
        ["Pricing_Billing_Start_Date_Dt__c", "Billing Start Date (for consumption)"],
        ["Pricing_Group_Type_nm__c", "Group Type"],
        ["Pricing_Additional_T_C_s_Txt__c", "Additional T's & C's"],
        ["Pricing_RegionQL_Nm__c", "Region"],
        ["Pricing_pm_approval_comments_nm__c", "Approval Comments"],
        ["Pricing_Deal_Description__c", "Deal Description"],
        ["Pricing_Manager__c", "Pricing Manager"]
    ]);

    @track softWarning_quoteLineListtoUpdate = [];
    @track softWarning_quoteLineIdList = [];
    showSoftWarningApprovedECAP = false;
    @track softWarningApprovedECAPLabel = SoftWarningApprovedECAPLabel;
    @track searchResults = []; // Stores search suggestions
    searchValue = '';

    openDataTable() {
        this.openModal = true;
        this.getQuoteLineDetailstoDisplay();
    }

    getQuoteLineDetailstoDisplay() {
        this.isSpinner = true;
        this.isNoData = false;
        this.data = [];

        getQuoteLineforTable({ quoteId: this.recordId })
            .then(result => {
                this.data = result;
                this.quoteId = this.recordId;
                if (this.data.length == 0) {
                    this.isNoData = true;   
                    this.msg = 'There are no quote lines available for Update Deal';
                    this.isSpinner = false;
                }
                else {
                    this.bulkFieldstoDisplay = bulkFields.split(',');
                    this.showLabel = true;
                    for (let i = 0; i < this.data.length; i++) {
                        this.accId = this.data[i].SBQQ__Quote__r.SBQQ__Account__c;
                        this.quoteRegion = this.data[i].SBQQ__Quote__r.Pricing_Region_Nm__c;
                        this.data[i]["oldApprovedQuantity"] = this.data[i].Pricing_Approved_Unit_Qty__c;
                        this.data[i]["isSelected"] = false;
                        this.data[i].Pricing_Backdate_Reason_Txt__c = this.data[i].Pricing_Backdate_Reason_Txt__c != undefined ? this.data[i].Pricing_Backdate_Reason_Txt__c : '';
                        this.data[i]["oldBackDateReason"] = this.data[i].Pricing_Backdate_Reason_Txt__c;
                        this.data[i]["oldPayableQty"] = this.data[i].Pricing_Payable_Quantity__c == undefined ? '' : this.data[i].Pricing_Payable_Quantity__c;
                        this.data[i]["oldEcapPriceAmount"] = this.data[i].Pricing_ECAP_Price_Amt__c;
                        this.data[i]["oldEffStartDate"] = this.data[i].Pricing_Revised_Pricing_Start_Date_dt__c;
                        this.data[i]["oldMeetcomp"] = this.data[i].Pricing_Meet_Comp_Price_Amt__c;
                        this.data[i]["oldApproveStartDt"] = this.data[i].Pricing_Approved_Start_Date_Dt__c;
                        this.data[i]["oldApproveEndDt"] = this.data[i].Pricing_Approved_End_Date_Dt__c;
                        this.data[i]["product"] = this.data[i].Pricing_Product_Nm__r.Name;
                        //? this.data[i].Pricing_Family_Name_Nm__c : 
                        //  this.data[i].Pricing_Program_Type_Nm__c == pmemQuoteLine || this.data[i].Pricing_Program_Type_Nm__c == nicQuoteLine || this.data[i].Pricing_Program_Type_Nm__c == DCGPUQuoteLine ? this.data[i].Pricing_DealProduct_Nm__c :
                        //      this.data[i].Pricing_Processor_Number_Nm__c;
                        this.data[i]["competitorProduct"] = this.data[i].Pricing_Program_Type_Nm__c == pmemQuoteLine ? '' :
                            this.data[i].Pricing_Program_Type_Nm__c == ssdQuoteLine || this.data[i].Pricing_Program_Type_Nm__c == nicQuoteLine ? this.data[i].Pricing_Comp_Product_Txt__c :
                                this.data[i].Pricing_Other_Competitor_Product_Nm__c == '' || this.data[i].Pricing_Other_Competitor_Product_Nm__c == undefined ? this.data[i].hasOwnProperty('Pricing_Competetor_Product__r') ? this.data[i].Pricing_Competetor_Product__r.Name : '' :
                                    this.data[i].Pricing_Other_Competitor_Product_Nm__c;
                        this.data[i]["backDateReason"] = this.data[i].Pricing_Backdate_Reason_Txt__c == undefined || this.data[i].Pricing_Backdate_Reason_Txt__c == '' ? '--None--' : this.data[i].Pricing_Backdate_Reason_Txt__c;
                        this.data[i]["pricingManager"] = this.data[i].hasOwnProperty('Pricing_Manager__r') ? this.data[i].Pricing_Manager__r.Name : '';
                        this.data[i]["searchKey"] = '';
                        this.data[i]["recordsList"] = '';
                        this.data[i]["message"] = '';
                        this.data[i]["isExisting"] = true;
                        console.log('1Pricing_Backdate_Reason_Txt__c => '+ JSON.stringify(this.data[i].Pricing_Backdate_Reason_Txt__c));
                    }
                }
                this.isSpinner = false;
            }).then(_ => {
                this.wiredPicklistValues();
                this.getRestrictedAccount();
            })
            .catch((error) => {
                console.error('Error in getQuoteLine: ' + error);
                this.isSpinner = false;
            });
    }

    addNewRow() {
        this.data = [...this.data, { 
            id: Date.now(), 
            Name: '', 
            ProductName: '', 
            Quantity: 0, 
            UnitPrice: 0,
            isExisting: false // Mark as a new row
        }];
    }

    handleSearch(event) {
        this.searchValue = event.target.value;
        const rowId = event.target.dataset.rowid; // Get row ID

        if (this.searchValue.length > 2) {
            searchQuoteLines({ searchTerm: this.searchValue })
                .then(result => {
                    this.searchResults = result.map(item => ({
                        Id: item.Id,
                        Name: item.Name,
                        ProductName: item.Product2.Name,
                        Quantity: item.Quantity,
                        UnitPrice: item.UnitPrice,
                        rowId: rowId // Keep track of which row this is for
                    }));
                })
                .catch(error => {
                    console.error('Error fetching Quote Line data', error);
                });
        }
    }

    handleSelect(event) {
        const selectedId = event.currentTarget.dataset.id;
        const rowId = event.currentTarget.dataset.rowid;
        const selectedRecord = this.searchResults.find(item => item.Id === selectedId);

        if (selectedRecord) {
            this.data = this.data.map(row => 
                row.id == rowId ? { ...selectedRecord, id: row.id, isExisting: false } : row
            );
        }

        this.searchResults = []; // Clear search results after selection
    }
    getRestrictedAccount() {
        getRestrictedAccount({ recordId: this.accId, pricingRegion: this.quoteRegion })
            .then(result => {
                this.restrictedAcc = result;
            }).catch((error) => {
                console.error('Error in getQuoteLine: ' + error);
            });
    }

    wiredPicklistValues() {
        getPicklistBulkDealController()
            .then(result => {
                this.options = [...this.options, { value: '--None--', label: '--None--' }]; // Pricing_Backdate_Reason_Txt__c           
                for (let i = 0; i < result[0].length; i++) {
                    this.options = [...this.options, { value: result[0][i], label: result[0][i] }];
                }

            }).then(_ => {
                this.isSpinner = false;
            })
            .catch(error => {
                console.error('Error @ getPicklistBulkDealController', JSON.stringify(error));
                this.isSpinner = false;
            });
    }

    closeModal() {
        this.isSpinner = false;
        this.openModal = false;
        this.options.length = 0;
        this.errorMsg = '';
        this.showBtn = false;
        this.showSoftWarningApprovedECAP = false;
        eval('$A.get(\'e.force:refreshView\').fire();');
    }

    handleReqUnitPrice(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Req_Discounted_Unit_Price__c = event.target.value;
        this.data = [...this.data];
    }

    handleApproveStartDate(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Approved_Start_Date_Dt__c = event.target.value;
        this.data = [...this.data];
        //this.approveStartDtChange = true;
    }

    handleApproveEndDate(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Approved_End_Date_Dt__c = event.target.value;
        this.data = [...this.data];
        //this.approveEndDtChange = true;
    }


    handleEffectiveDate(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Revised_Pricing_Start_Date_dt__c = event.target.value;
        this.data = [...this.data];
        //this.effStartDateChanged = true;
    }

    handleBillingStartDate(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Billing_Start_Date_Dt__c = event.target.value;
        this.data = [...this.data];
    }

    handleBillingEndDate(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Billing_End_Date_Dt__c = event.target.value;
        this.data = [...this.data];
    }

    handleApprovedQuantity(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Approved_Unit_Qty__c = event.target.value;
        this.data = [...this.data];
    }

    handlePayableQuantity(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Payable_Quantity__c = event.target.value;
        this.data = [...this.data];
    }

    handleApproveECAPPrice(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_ECAP_Price_Amt__c = event.target.value;
        this.data = [...this.data];
    }

    handleBackDateReason(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Backdate_Reason_Txt__c = event.target.value == '--None--' ? '' : event.target.value;
        console.log('Pricing_Backdate_Reason_Txt__c => '+ JSON.stringify(element.Pricing_Backdate_Reason_Txt__c));
        this.data = [...this.data];
    }

    handleMeetCompPrice(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Meet_Comp_Price_Amt__c = event.target.value;
        this.data = [...this.data];

    }

    handleDealDescription(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Deal_Description__c = event.target.value;
        this.data = [...this.data];
    }

    handleApprovalComments(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_pm_approval_comments_nm__c = event.target.value;
        this.data = [...this.data];
    }

    handleAdditionalTC(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Additional_T_C_s_Txt__c = event.target.value;
        this.data = [...this.data];
    }

    handleAdditionalComments(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Additional_Comments_Txt__c = event.target.value;
        this.data = [...this.data];
    }

    handlePricingManager(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Manager__c = event.target.value;
        this.data = [...this.data];
    }

    handleCheckBox(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.isSelected = event.target.checked;
        this.data = [...this.data];
        let allSelect = this.template.querySelector(`[data-id="selectAllCheckBox"]`);
        allSelect.checked = event.target.checked == false ? false : false;
    }


    allSelected(event) {
        let selectedRows = this.template.querySelectorAll('lightning-input');
        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = event.target.checked;
                if (i > 0) {
                    let element = this.data.find(ele => ele.Id === selectedRows[i].dataset.id);
                    element.isSelected = event.target.checked;
                    this.data = [...this.data];
                }
            }
        }
    }

    handleSave() {
        this.isSpinner = true;
        this.showBtn = true;
        this.isSave = true;
        this.isUpdateDeal = false;
        this.handleValidation();
    }

    handleDealCreation() {
        this.isSpinner = true;
        this.showBtn = true;
        this.isUpdateDeal = true;
        this.isSave = false;
        this.handleValidation();
    }


    handleValidation() {
        let quoteLineListtoUpdate = [];
        let quoteLineIdList = [];
        let selectedRowCount = 0;
        let errorCount = 0;
        let date = new Date().toJSON().slice(0, 10);
        this.requiredFields = mandatoryFields.split(':');
        let softWarningApprovedECAPFlag = false;
        for (let j in this.data) {
            this.data[j]["isError"] = false;
            this.data[j]["isWarning"] = false;
            this.data[j]["errorMsg"] = '';
            if (this.data[j].isSelected == true) {
                selectedRowCount++;
            }
        }
        if (selectedRowCount == 0) {
            const toastMessage = new ShowToastEvent({
                title: 'Error',
                message: 'Please select at least one row to proceed.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(toastMessage);
            this.isSpinner = false;
            this.showBtn = false;
        }
        else if (selectedRowCount > 0) {
            for (let i in this.data) {
                if (this.data[i].isSelected == true) {

                    let validationMsg = '';
                    let error = '';
                    let latinCharError = '';
                    let isInflightFutureDeal = false;

                    quoteLineListtoUpdate.push(this.data[i]);
                    quoteLineIdList.push(this.data[i].Id);

                    if (this.isUpdateDeal) {
                        for (let fieldStr in this.requiredFields) {
                            let fld = this.requiredFields[fieldStr];
                            if (this.data[i][fld] == '' || this.data[i][fld] == undefined) {
                                if (this.data[i].Pricing_Program_Type_Nm__c != ccgQuoteLine &&
                                    (fld != 'Pricing_Meet_Comp_Price_Amt__c' || (fld == 'Pricing_Meet_Comp_Price_Amt__c' &&
                                        (this.data[i].Pricing_Program_Type_Nm__c != pmemQuoteLine &&
                                            this.data[i].Pricing_Program_Type_Nm__c != ssdQuoteLine)))) {
                                    error = error + (this.quoteLineFieldsMap.get(this.requiredFields[fieldStr])) + '\n';
                                }
                                if (this.data[i].Pricing_Program_Type_Nm__c == ccgQuoteLine &&
                                    (fld != 'Pricing_Market_Segment_values_Nm__c' && fld != 'Pricing_Market_Segment_Nm__c')) {
                                    error = error + (this.quoteLineFieldsMap.get(this.requiredFields[fieldStr])) + '\n';
                                }
                            }
                        }
                        let ecapPrice = this.data[i].Pricing_ECAP_Price_Amt__c == null || this.data[i].Pricing_ECAP_Price_Amt__c == undefined || this.data[i].Pricing_ECAP_Price_Amt__c == '' ? 0 : parseInt(this.data[i].Pricing_ECAP_Price_Amt__c);
                        let meetCompPrice = this.data[i].Pricing_Meet_Comp_Price_Amt__c == null || this.data[i].Pricing_Meet_Comp_Price_Amt__c == undefined || this.data[i].Pricing_Meet_Comp_Price_Amt__c == '' ? 0 : parseInt(this.data[i].Pricing_Meet_Comp_Price_Amt__c);
                        if ((this.data[i].Pricing_Program_Type_Nm__c == ccgQuoteLine) && (((this.data[i].hasOwnProperty('Pricing_ECAP_Price_Amt__c')) && (ecapPrice)) < ((this.data[i].hasOwnProperty('Pricing_Meet_Comp_Price_Amt__c')) && (meetCompPrice)))) {
                            softWarningApprovedECAPFlag = true;
                        }
                    }

                    let newpayableQty = this.data[i].Pricing_Payable_Quantity__c == undefined ? '' : this.data[i].Pricing_Payable_Quantity__c
                    if ((this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c <= date && this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c >= date) || this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c > date) {
                        isInflightFutureDeal = true;
                    }

                    if (!this.restrictedAcc && newpayableQty != this.data[i].oldPayableQty) {
                        validationMsg += payableQtyEditError;
                    }

                    if (this.restrictedAcc && newpayableQty != this.data[i].oldPayableQty && this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c == qlApprovedStatus) {
                        validationMsg += payableQtyEditWonQlError;
                    }

                    if (this.restrictedAcc && newpayableQty > this.data[i].Pricing_Approved_Unit_Qty__c) {
                        validationMsg += payableQtyEcxeedError;
                    }
                    if ((this.data[i].Pricing_Meet_Comp_Price_Amt__c != this.data[i].oldMeetcomp || this.data[i].Pricing_Revised_Pricing_Start_Date_dt__c != this.data[i].oldEffStartDate) && (this.data[i].Pricing_Approved_Unit_Qty__c == this.data[i].oldApprovedQuantity && this.data[i].Pricing_Approved_Start_Date_Dt__c == this.data[i].oldApproveStartDt && this.data[i].Pricing_Approved_End_Date_Dt__c == this.data[i].oldApproveEndDt && this.data[i].Pricing_ECAP_Price_Amt__c == this.data[i].oldEcapPriceAmount && newpayableQty == this.data[i].oldPayableQty)) {
                        validationMsg += meetCompAndEfftiveDtaeError;
                    }

                    if ((this.data[i].Pricing_Meet_Comp_Price_Amt__c && this.data[i].Pricing_Meet_Comp_Price_Amt__c != undefined) && this.data[i].Pricing_Meet_Comp_Price_Amt__c <= 0) {
                        validationMsg += meetCompPriceError;
                    }
                    if ((this.data[i].Pricing_Approved_Unit_Qty__c && this.data[i].Pricing_Approved_Unit_Qty__c != undefined) && this.data[i].Pricing_Approved_Unit_Qty__c <= 0) {
                        validationMsg += approvedQuantityError;
                    }
                    if ((this.data[i].Pricing_ECAP_Price_Amt__c && this.data[i].Pricing_ECAP_Price_Amt__c != undefined) && this.data[i].Pricing_ECAP_Price_Amt__c <= 0) {
                        validationMsg += ecapPriceError;
                    }

                    if (this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c < date && this.data[i].Pricing_ECAP_Price_Amt__c != this.data[i].oldEcapPriceAmount) {
                        validationMsg += ecapPricePastDealEditError;
                    }

                    if (this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c < date && this.data[i].Pricing_Revised_Pricing_Start_Date_dt__c != this.data[i].oldEffStartDate) {
                        validationMsg += effDatePastDealEditError;
                    }

                    if (this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c == qlApprovedStatus && this.data[i].Pricing_Revised_Pricing_Start_Date_dt__c != this.data[i].oldEffStartDate) {
                        validationMsg += effDateApprovedQlEditError;
                    }

                    if (this.data[i].Pricing_Revised_Pricing_Start_Date_dt__c != this.data[i].oldEffStartDate && (this.data[i].Pricing_Revised_Pricing_Start_Date_dt__c == '' || this.data[i].Pricing_Revised_Pricing_Start_Date_dt__c == null)) {
                        validationMsg += effDateBlankError;
                    }
                    if (isInflightFutureDeal && this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c == qlWonStatus && ((this.data[i].Pricing_Revised_Pricing_Start_Date_dt__c < this.data[i].Pricing_Approved_Start_Date_Dt__c || this.data[i].Pricing_Revised_Pricing_Start_Date_dt__c > this.data[i].Pricing_Approved_End_Date_Dt__c) || (this.data[i].Pricing_Revised_Pricing_Start_Date_dt__c < this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c))) {
                        validationMsg += effectiveDateError;
                    }

                    if (this.data[i].Pricing_Approved_Start_Date_Dt__c != this.data[i].oldApproveStartDt && ((this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c <= date && this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c >= date &&
                        this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c == qlWonStatus) || this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c < date)) {
                        validationMsg += startDateEditError;
                    }
                    if (this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c < date && this.data[i].Pricing_Approved_End_Date_Dt__c < this.data[i].Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c) {
                        validationMsg += approvedEndDtPastError;
                    }
                    if (this.data[i].Pricing_Approved_End_Date_Dt__c < this.data[i].Pricing_Approved_Start_Date_Dt__c) {
                        validationMsg += endDateBeforeStartDate;
                    }
                    if (this.data[i].Pricing_Billing_Start_Date_Dt__c > this.data[i].Pricing_Approved_Start_Date_Dt__c) {
                        validationMsg += billingStartDateError;
                    }
                    if (this.data[i].Pricing_Billing_End_Date_Dt__c > this.data[i].Pricing_Approved_End_Date_Dt__c) {
                        validationMsg += billingEndDateError;
                    }
                    if (this.data[i].Pricing_Billing_End_Date_Dt__c < this.data[i].Pricing_Billing_Start_Date_Dt__c) {
                        validationMsg += billingDateError;
                    }

                    if ((this.data[i].Pricing_Backdate_Reason_Txt__c != this.data[i].oldBackDateReason) && this.data[i].Pricing_Approved_Start_Date_Dt__c >= date) {
                        validationMsg += 'Back Date Reason can only be edited when Approved Pricing Start Date is in the past.';
                    }

                    if ((this.data[i].Pricing_Backdate_Reason_Txt__c == undefined || this.data[i].Pricing_Backdate_Reason_Txt__c == '') 
                        && this.data[i].Pricing_Approved_Start_Date_Dt__c < date && this.data[i].Pricing_Approved_Start_Date_Dt__c != this.data[i].oldApproveStartDt ) {
                        error += 'Backdate Reason' + '\n';
                    }

                    if (this.isUpdateDeal && this.data[i].Pricing_Approved_End_Date_Dt__c != undefined && this.data[i].Pricing_Approved_End_Date_Dt__c < date) {
                        validationMsg += pastDateError;
                    }

                    if (this.isUpdateDeal && this.data[i].Pricing_Billing_Start_Date_Dt__c != undefined && this.data[i].Pricing_Approved_Start_Date_Dt__c != undefined) {
                        var startDate = new Date(this.data[i].Pricing_Approved_Start_Date_Dt__c);
                        console.log('Entered update deal');
                        var billingDate = new Date(this.data[i].Pricing_Billing_Start_Date_Dt__c);
                        let difference = startDate - billingDate;
                        let noOfDaysBetweenDates = Math.ceil(difference / (1000 * 3600 * 24))
                        if (noOfDaysBetweenDates > noOfDays) {
                            validationMsg += billingQuarterError;
                        }
                    }

                    if ((this.data[i].Pricing_Additional_T_C_s_Txt__c != '' && this.data[i].Pricing_Additional_T_C_s_Txt__c != undefined) && !this.data[i].Pricing_Additional_T_C_s_Txt__c.match(latinCharCheck)) {
                        latinCharError += 'Additional T\'s & C\'s ; ';
                    }

                    if ((this.data[i].Pricing_Deal_Description__c != '' && this.data[i].Pricing_Deal_Description__c != undefined) && !this.data[i].Pricing_Deal_Description__c.match(latinCharCheck)) {
                        latinCharError += ' Deal Description ; ';
                    }

                    if ((this.data[i].Pricing_Additional_Comments_Txt__c != '' && this.data[i].Pricing_Additional_Comments_Txt__c != undefined) && !this.data[i].Pricing_Additional_Comments_Txt__c.match(latinCharCheck)) {
                        latinCharError += ' Additional Comments ; ';
                    }

                    if (latinCharError.length > 0) {
                        validationMsg += latinErrorMsg + 'Please review following fields : ' + latinCharError.slice(0, -2) + '.';
                    }

                    if (error != '' || validationMsg != '') {
                        errorCount++;
                        var msgdisplay = 'The following fields are required to update Deal:';
                        let errorMsgtoDisplay = error != '' ? validationMsg + '\n' + msgdisplay + '\n' + error : validationMsg;
                        this.data[i]["isError"] = true;
                        this.data[i]["errorMsg"] = errorMsgtoDisplay;
                    }
                    this.errorList = [...this.errorList, { key: this.data[i].Id, value: error }];
                }
            }
        }

        if (errorCount > 0) {
            const toastMessage = new ShowToastEvent({
                title: 'Error',
                message: 'Error has occurred while processing. Please hover over the error indicator for more detail',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(toastMessage);
            this.isSpinner = false;
            this.showBtn = false;
        }
        else if (errorCount == 0 && selectedRowCount > 0) {
            if (this.isUpdateDeal && softWarningApprovedECAPFlag) {
                this.softWarning_quoteLineListtoUpdate = quoteLineListtoUpdate;
                this.softWarning_quoteLineIdList = quoteLineIdList;
                this.showSoftWarningApprovedECAP = true;
            }
            else {
                this.invokeSaveandDealCreation(quoteLineListtoUpdate, quoteLineIdList);
            }

        }
    }



    invokeSaveandDealCreation(quoteLineListtoUpdate, quoteLineIdList) {
        let apexErrorCount = 0;
        updateQuotelines({ quoteLineListtoUpdate: quoteLineListtoUpdate, parentId: quoteLineIdList, isCreateDeal: false, isUpdateDeal: this.isUpdateDeal })
            .then(result => {
                if (this.isSave) {
                    const toastMessage = new ShowToastEvent({
                        title: 'Success',
                        message: 'Quote Lines Saved successfully.',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(toastMessage);
                    this.isSpinner = false;
                    this.showBtn = false;
                }
                else {
                    for (let i in quoteLineListtoUpdate) {
                        if (result[quoteLineListtoUpdate[i].Id] != 'Success') {
                            apexErrorCount++;
                            let element = this.data.find(ele => ele.Id === quoteLineListtoUpdate[i].Id);
                            element.isError = true;
                            element.errorMsg = result[quoteLineListtoUpdate[i].Id];
                            this.data = [...this.data];
                        }
                    }
                    if (apexErrorCount == 0) {
                        const toastMessage = new ShowToastEvent({
                            title: 'Success',
                            message: 'Quote Lines are send to MyDeals.',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(toastMessage);
                        this.isSpinner = false;
                        this.showBtn = false;
                        this.isSpinner = false;
                        this.openModal = false;
                        this.options.length = 0;
                        this.errorMsg = '';
                        eval('$A.get(\'e.force:refreshView\').fire();');
                    } else {
                        const toastMessage = new ShowToastEvent({
                            title: 'Error',
                            message: 'Error has occured for Quote Lines while Deal Creation.',
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(toastMessage);
                        this.isSpinner = false;
                        this.showBtn = false;

                    }
                }
            })
            .catch(error => {
                console.error('Error @ invokeSaveandDealCreation ===>', JSON.stringify(error));
                this.isSpinner = false;
                this.showBtn = false;
            });
    }


    calculateWidth(event) {
        var childObj = event.target;
        var parObj = childObj.parentNode;
        var count = 1;
        while (parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        var mouseStart1 = event.clientX;
        this.mouseStart = mouseStart1;
        this.oldWidth = parObj.offsetWidth;
    }

    setNewWidth(event) {
        var childObj = event.target;
        var parObj = childObj.parentNode;
        var count = 1;
        while (parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        var mouseStart1 = this.mouseStart;
        var oldWidth1 = this.oldWidth;
        var newWidth = event.clientX - parseFloat(mouseStart1) + parseFloat(oldWidth1);
        parObj.style.width = newWidth + 'px';
    }



    removeRecordOnLookup(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.searchKey = '';
        element.recordsList = null;
        element.Pricing_Manager__c = null;
        element.Pricing_Manager__r = {};
        element.pricingManager = '';
        this.data = [...this.data];
    }

    onLeave(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        setTimeout(() => {
            element.searchKey = '';
            element.recordsList = null;
        }, 300);
        this.data = [...this.data];
    }

    handleKeyChange(event) {
        clearTimeout(this.typingTimer);
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.searchKey = event.target.value;
        this.data = [...this.data];
        const thisKey = this;
        this.typingTimer = setTimeout(function () {
            thisKey.getLookupResult(element.Id);
        }.bind(this), 1000);
    }

    handleKeyDown() {
        clearTimeout(this.typingTimer);
    }

    getLookupResult(id) {
        let element = this.data.find(ele => ele.Id === id);
        findRecords({ searchKey: element.searchKey })
            .then((result) => {
                console.log('Enetered Find records method(CHange Request): '+result);
                if (result.length == 0 || result == '') {
                    element.recordsList = [];
                    element.message = 'No Records Found';
                    this.data = [...this.data];
                } else {
                    element.recordsList = result;
                    element.message = '';
                }
                this.error = null;
            })
            .catch((error) => {
                this.error = error;
                console.error('Error @ findRecords ' + JSON.stringify(this.error));
                element.recordsList = null;
            });
    }

    onRecordSelection(event) {
        if (this.pricingManagerQLineId != '') {
            let element = this.data.find(ele => ele.Id === this.pricingManagerQLineId);
            element["Pricing_Manager__c"] = event.target.dataset.key;
            element["Pricing_Manager__r"] = {
                Id: event.target.dataset.key,
                Name: event.target.dataset.name
            };
            element.pricingManager = event.target.dataset.name;
            this.data = [...this.data];
        }
    }

    onfocusPricingmanager(event) {
        this.pricingManagerQLineId = event.target.dataset.id;
    }

    handleContinueSoftWarning() {
        this.showSoftWarningApprovedECAP = false;
        this.invokeSaveandDealCreation(this.softWarning_quoteLineListtoUpdate, this.softWarning_quoteLineIdList);
    }
}