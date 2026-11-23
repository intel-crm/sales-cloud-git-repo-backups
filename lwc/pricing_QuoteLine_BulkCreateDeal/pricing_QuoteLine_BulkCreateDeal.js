import { LightningElement, track, api, wire } from 'lwc';
import getQuoteLineforTable from '@salesforce/apex/Pricing_QuoteLine_BulkDealController.getQuoteLineDetails';
import ccgQuoteLine from '@salesforce/label/c.Pricing_Tender_CCG_Quote';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateQuotelines from '@salesforce/apex/Pricing_QuoteLine_BulkDealController.updateQuoteLineDetails';
import makeCallout from '@salesforce/apex/Pricing_PricingAI_BulkController.makeCallout';
import getPicklistBulkDealController from '@salesforce/apex/Pricing_QuoteLine_BulkDealController.getPicklistBulkDealController';
import findRecords from '@salesforce/apex/Pricing_QuoteLine_BulkDealController.findRecords';
import getExcludedEndCustomerList from '@salesforce/apex/Pricing_QuoteLine_BulkDealController.getCustomSettingRecordsforExcludedList';
import accountToCIMIdMtdRecord from '@salesforce/apex/Pricing_QuoteLine_BulkDealController.accountToCIMIdMappingMtdRec';

//labels having error messages
import daysIfNoAccountPresentInMtd from '@salesforce/label/c.Pricing_NoOfDays_NotPresent_CIMIdMtd';
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
import allowedBillingDateBackDatingDays from '@salesforce/label/c.Pricing_AllowedBillingDateBackDating_days';
import aiMeetCompErrorMsg from '@salesforce/label/c.Pricing_GetAI_MeetComp_Error_Message';
import processorQuoteLineType from '@salesforce/label/c.Pricing_Tender_Processors_Quote_Line_Type';
import noDataError from '@salesforce/label/c.Pricing_BulkDeal_ErrorMessage';
import bulkFields from '@salesforce/label/c.Pricing_BulkDeal_Fields';
import toolTip from '@salesforce/label/c.Pricing_BulkDeal_helpText';
import pricingAInotapplicableError from '@salesforce/label/c.Pricing_BulkDeal_PricinAI_Error';
import userHasValidRPMPermission from '@salesforce/apex/Pricing_QuoteLine_BulkDealController.userHasValidRPMPermission';
import programType from '@salesforce/label/c.Pricing_TenderProgramTypeForMeetCompAutoPopulate';
import application from '@salesforce/label/c.Pricing_TenderApplicationForMeetcompAutoPopulate';
import tentaticeEcapVal from '@salesforce/label/c.Pricing_TentaticeEcapValue_AutoAI';
import latinCharCheck from '@salesforce/label/c.Pricing_Latin_Characters_Regular_Expr_Label';
import latinErrorMsg from '@salesforce/label/c.Pricing_Non_Latin_Char_Validation_Error';
import AIfeedbackOtherMsg from '@salesforce/label/c.Pricing_AIFeedback_Other_ValidationMsg';
import standardQuoteLine from '@salesforce/label/c.Pricing_Tender_Standard_QuoteLine';
import Quantity from '@salesforce/label/c.Pricing_Quantity';
import stdQuoteLine from '@salesforce/label/c.Pricing_Tender_Standard_QuoteLine';
import Worklaod from "@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Workload_Nm__c";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import Quote_Line from "@salesforce/schema/SBQQ__QuoteLine__c";
import MandatoryWorkloadErrorMessage from '@salesforce/label/c.Pricing_Mandatory_Workload_Selection';
import NonMandatoryWorkloadErrorMessage from '@salesforce/label/c.Pricing_Non_Mandatory_Workload_Selection';
import Cosp from '@salesforce/label/c.Pricing_Tender_CoSP_Application_Value';
import DCGPUQuoteLine from '@salesforce/label/c.Pricing_Tender_DataCenter_GPU';
import SoftWarningLabel from '@salesforce/label/c.Pricing_Tender_Soft_Warning_for_Large_Enterprise';
import SoftWarningApprovedECAPLabel from '@salesforce/label/c.Pricing_Tender_Approved_ECAP';
import isActive from '@salesforce/apex/Pricing_PricingAI_BulkController.isPricingAIEnabled';

export default class Pricing_QuoteLine_BulkCreateDeal extends LightningElement {
    @api recordId;
    @track dataTableColumns;
    @track quoteLineList = [];
    @track quoteLineListforDisplay = [];
    @track openModal = false;
    @track errorMsg = '';
    @track saveDraftValues;
    @track data = [];
    @track quoteLineId = [];
    @track action;
    @track isSpinner = false;
    @track errorList = [];
    @track quotelineSelected = [];
    @api objectApiName;
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
    @track options = [];
    @track feedBackOptions = [];
    @track requiredFields;
    @track errorString;
    @track isopenButton = false;
    @track oldWidth;
    @track mouseStart;
    @track isCreateDeal = false;
    @track isAI = false;
    @track isSave = false;
    @track isNoData = false;
    msg;
    @track showBtn = true;
    @track bulkFieldstoDisplay = [];
    @track showLabel = false;
    @track isAutoAI = false;
    @track date;
    @track dateBeforeSixMonth;
    @track dateBeforeSixMonthFromToday;
    @track dateAfterYear;
    @track endCustomerList = [];
    label = {
        toolTip
    };

    @track selectedRecord;
    @track message;
    @track regionQLOptions = [];
    @track pricingManagerQLineId = '';
    typingTimer;
    @track billingStartDateFromMtd;
    @track accId;
    @track accIdToNoOfDaysMap = new Map();
    @track isClient = false;

    @track workloadpicklistOptions = [];
    @track softWarning_quoteLineListtoUpdate = [];
    @track softWarning_quoteLineIdList = [];
    showSoftWarning = false;
    showSoftWarningApprovedECAP = false;
    showSoftWarningSIPPandECAP = false;
    @track softWarningLabel = SoftWarningLabel;
    @track softWarningApprovedECAPLabel = SoftWarningApprovedECAPLabel;
    pricingAIEnabled;

    openDataTable() {
        this.openModal = true;
        isActive({ functionalityName: 'Pricing_AI' }).then(result => {
            this.pricingAIEnabled = result;
        });
        accountToCIMIdMtdRecord()
            .then(result => {
                this.accIdToNoOfDaysMap = result;
            })
            .then(_ => {
                this.getQuoteLineDetailstoDisplay();
            })
            .catch(error => {
                console.error('Error @ accountToCIMIdMtdRecord ---->:' + JSON.stringify(error));
            });
    }

    getQuoteLineDetailstoDisplay() {
        this.isSpinner = true;
        this.isNoData = false;
        this.data = [];

        getExcludedEndCustomerList()
            .then(result => {
                this.endCustomerList = result;
            })
            .catch(error => {
                console.error('Error @ getExcludedEndCustomerList : ' + JSON.stringify(error));
            });

        getQuoteLineforTable({ quoteId: this.recordId })
            .then(result => {
                this.data = result;
                if (this.data.length == 0) {
                    this.isNoData = true;
                    this.msg = noDataError;
                    this.isSpinner = false;
                }
                else {
                    let quoteLineIdList = [];
                    this.bulkFieldstoDisplay = bulkFields.split(',');

                    this.showLabel = true;
                    this.date = new Date().toJSON().slice(0, 10);
                    this.dateAfterYear = new Date(new Date().setDate(new Date().getDate() + 365)).toJSON().slice(0, 10);
                    this.dateBeforeSixMonthFromToday = new Date(new Date().setDate(new Date().getDate() - daysIfNoAccountPresentInMtd)).toJSON().slice(0, 10);

                    for (let i = 0; i < this.data.length; i++) {
                        this.data[i]["isSelected"] = false;
                        this.data[i].Pricing_Backdate_Reason_Txt__c = this.data[i].Pricing_Backdate_Reason_Txt__c != undefined ? this.data[i].Pricing_Backdate_Reason_Txt__c : '';
                        this.data[i]["oldBackDateReason"] = this.data[i].Pricing_Backdate_Reason_Txt__c;
                        this.data[i]["product"] = this.data[i].Pricing_Program_Type_Nm__c == ssdQuoteLine ? this.data[i].Pricing_Family_Name_Nm__c :
                            this.data[i].Pricing_Program_Type_Nm__c == pmemQuoteLine || this.data[i].Pricing_Program_Type_Nm__c == nicQuoteLine || this.data[i].Pricing_Program_Type_Nm__c == DCGPUQuoteLine ? this.data[i].Pricing_DealProduct_Nm__c :
                                this.data[i].Pricing_Processor_Number_Nm__c;
                        this.data[i]["competitorProduct"] = this.data[i].Pricing_Program_Type_Nm__c == pmemQuoteLine ? '' :
                            this.data[i].Pricing_Program_Type_Nm__c == ssdQuoteLine || this.data[i].Pricing_Program_Type_Nm__c == nicQuoteLine ? this.data[i].Pricing_Comp_Product_Txt__c :
                                this.data[i].Pricing_Other_Competitor_Product_Nm__c == '' || this.data[i].Pricing_Other_Competitor_Product_Nm__c == undefined ? this.data[i].hasOwnProperty('Pricing_Competetor_Product__r') ? this.data[i].Pricing_Competetor_Product__r.Name : '' :
                                    this.data[i].Pricing_Other_Competitor_Product_Nm__c;
                        this.data[i]["backDateReason"] = this.data[i].Pricing_Backdate_Reason_Txt__c == undefined || this.data[i].Pricing_Backdate_Reason_Txt__c == '' ? '--None--' : this.data[i].Pricing_Backdate_Reason_Txt__c;
                        this.data[i]["feedbackReason"] = this.data[i].Pricing_Recommendation_FeedBack_Nm__c == undefined || this.data[i].Pricing_Recommendation_FeedBack_Nm__c == '' ? '--None--' : this.data[i].Pricing_Recommendation_FeedBack_Nm__c;
                        this.data[i]["pricingManager"] = this.data[i].hasOwnProperty('Pricing_Manager__r') ? this.data[i].Pricing_Manager__r.Name : '';
                        this.data[i]["searchKey"] = '';
                        this.data[i]["recordsList"] = '';
                        this.data[i]["message"] = '';
                        this.data[i]["isDataCenterCPU"] = this.data[i].Pricing_Program_Type_Nm__c == stdQuoteLine ? true : false;

                        this.accId = 'Id_' + this.data[i].SBQQ__Quote__r.SBQQ__Account__c;
                        if (this.data[i].Pricing_Program_Type_Nm__c == ccgQuoteLine && (this.data[i].Pricing_Tentative_ECAP_Price_Amt__c === '' || this.data[i].Pricing_Tentative_ECAP_Price_Amt__c === undefined)) {
                            this.isClient = true;
                            quoteLineIdList.push(this.data[i].Id);
                        }
                        if (programType.split(',').includes(this.data[i].Pricing_Program_Type_Nm__c) && application.split(',').includes(this.data[i].SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c) &&
                            (this.data[i].Pricing_Program_Type_Nm__c != standardQuoteLine || (this.data[i].Pricing_Program_Type_Nm__c == standardQuoteLine && this.data[i].Pricing_Unit_Qty__c <= Quantity && (this.data[i].SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c != 'CSP' ||
                                (this.data[i].SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c == 'CSP' && !this.endCustomerList.includes(this.data[i].Pricing_EndCustomer_Nm__c)))))) {
                            this.isAutoAI = true;
                            this.data[i].Pricing_Approved_Start_Date_Dt__c = this.data[i].Pricing_Approved_Start_Date_Dt__c === '' || this.data[i].Pricing_Approved_Start_Date_Dt__c === undefined ? this.date : this.data[i].Pricing_Approved_Start_Date_Dt__c;
                            this.data[i].Pricing_Approved_End_Date_Dt__c = this.data[i].Pricing_Approved_End_Date_Dt__c === '' || this.data[i].Pricing_Approved_End_Date_Dt__c === undefined ? this.dateAfterYear : this.data[i].Pricing_Approved_End_Date_Dt__c;

                            this.data[i].Pricing_Billing_End_Date_Dt__c = this.data[i].Pricing_Billing_End_Date_Dt__c === '' || this.data[i].Pricing_Billing_End_Date_Dt__c === undefined ? this.dateAfterYear : this.data[i].Pricing_Billing_End_Date_Dt__c;
                            if ((this.data[i].Pricing_Tentative_ECAP_Price_Amt__c === '' || this.data[i].Pricing_Tentative_ECAP_Price_Amt__c === undefined) && (this.data[i].Pricing_Meet_Comp_Price_Amt__c != '' && this.data[i].Pricing_Meet_Comp_Price_Amt__c != undefined)) {
                                quoteLineIdList.push(this.data[i].Id);
                            }
                        }
                        if (this.isAutoAI || this.isClient) {
                            if (this.accIdToNoOfDaysMap.size != 0 && this.accIdToNoOfDaysMap.hasOwnProperty(this.accId) === true) {
                                this.billingStartDateFromMtd = new Date(new Date().setDate(new Date().getDate() - this.accIdToNoOfDaysMap[this.accId])).toJSON().slice(0, 10);

                                //approveStartDate - no of days from CIM Id metadata for Client QL type if metadata record has no of days configured.
                                let approvedStartDate = new Date(this.data[i].Pricing_Approved_Start_Date_Dt__c);
                                let approvedStartDatePast = new Date(approvedStartDate);
                                approvedStartDatePast.setDate(approvedStartDate.getDate() - this.accIdToNoOfDaysMap[this.accId]);
                                var dateBeforeApproveStartDate = approvedStartDatePast.toJSON().slice(0, 10);
                                this.data[i].Pricing_Billing_Start_Date_Dt__c = (this.isAutoAI && (this.data[i].Pricing_Billing_Start_Date_Dt__c === '' || this.data[i].Pricing_Billing_Start_Date_Dt__c === undefined)) ? this.billingStartDateFromMtd : this.isClient ? dateBeforeApproveStartDate : this.data[i].Pricing_Billing_Start_Date_Dt__c;
                            }
                            else {
                                let approvedStartDate = new Date(this.data[i].Pricing_Approved_Start_Date_Dt__c);
                                let approveStartDatePast = new Date(approvedStartDate);
                                approveStartDatePast.setDate(approvedStartDate.getDate() - daysIfNoAccountPresentInMtd);
                                this.dateBeforeSixMonth = approveStartDatePast.toJSON().slice(0, 10);
                                //this.dateBeforeSixMonth = new Date(new Date().setDate(approvedStartDate.getDate() - 180)).toJSON().slice(0, 10);
                                this.data[i].Pricing_Billing_Start_Date_Dt__c = (this.isAutoAI && (this.data[i].Pricing_Billing_Start_Date_Dt__c === '' || this.data[i].Pricing_Billing_Start_Date_Dt__c === undefined)) ? this.dateBeforeSixMonthFromToday : this.isClient ? this.dateBeforeSixMonth : this.data[i].Pricing_Billing_Start_Date_Dt__c;
                            }
                            this.data[i].Pricing_Tentative_ECAP_Price_Amt__c = tentaticeEcapVal;
                            this.data[i].Pricing_Meet_Comp_Price_Amt__c = !this.isAutoAI && (this.data[i].Pricing_Meet_Comp_Price_Amt__c === '' || this.data[i].Pricing_Meet_Comp_Price_Amt__c === undefined) ? this.data[i].Pricing_Req_Discounted_Unit_Price__c : this.data[i].Pricing_Meet_Comp_Price_Amt__c;
                        }
                    }
                    if (this.pricingAIEnabled && (this.isAutoAI || this.isClient) && quoteLineIdList.length > 0) {
                        this.invokePricingAI(quoteLineIdList);
                    }
                    this.showBtn = false;
                }
            }).then(_ => {
                this.wiredPicklistValues();
            })
            .catch((error) => {
                console.error('Error in getQuoteLine: ' + error);
                this.isSpinner = false;
            });
    }


    wiredPicklistValues() {

        getPicklistBulkDealController()
            .then(result => {
                this.options = [...this.options, { value: '--None--', label: '--None--' }]; // Pricing_Backdate_Reason_Txt__c           
                this.feedBackOptions = [...this.feedBackOptions, { value: '--None--', label: '--None--' }];
                this.regionQLOptions = [...this.regionQLOptions, { value: '--None--', label: '--None--' }];
                for (let i = 0; i < result[0].length; i++) {
                    this.options = [...this.options, { value: result[0][i], label: result[0][i] }];
                }
                for (let j = 0; j < result[1].length; j++) {
                    this.feedBackOptions = [...this.feedBackOptions, { value: result[1][j], label: result[1][j] }];
                }
                for (let k = 0; k < result[2].length; k++) {
                    this.regionQLOptions = [...this.regionQLOptions, { value: result[2][k], label: result[2][k] }];
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
        this.isClient = false;
        this.options.length = 0;
        this.feedBackOptions.length = 0;
        this.regionQLOptions.length = 0;
        this.errorMsg = '';
        this.showSoftWarning = false;
        this.showSoftWarningApprovedECAP = false;
        this.showSoftWarningSIPPandECAP = false;
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
    }

    handleApproveEndDate(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Approved_End_Date_Dt__c = event.target.value;
        this.data = [...this.data];
    }

    handleApproveECAPPrice(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_ECAP_Price_Amt__c = event.target.value;
        this.data = [...this.data];
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

    handleBackDateReason(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Backdate_Reason_Txt__c = event.target.value == '--None--' ? '' : event.target.value;
        this.data = [...this.data];
    }

    handleMeetCompPrice(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Meet_Comp_Price_Amt__c = event.target.value;
        this.data = [...this.data];
    }

    handleCheckBox(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.isSelected = event.target.checked;
        this.data = [...this.data];
        let allSelect = this.template.querySelector(`[data-id="selectAllCheckBox"]`);
        allSelect.checked = event.target.checked == false ? false : false;
    }



    handleRecommendationFeedback(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Recommendation_FeedBack_Nm__c = event.target.value == '--None--' ? '' : event.target.value;
        this.data = [...this.data];
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
        this.isCreateDeal = false;
        this.isAI = false;
        this.handleValidation();
    }

    handleDealCreation() {
        this.isSpinner = true;
        this.showBtn = true;
        this.isCreateDeal = true;
        this.isSave = false;
        this.isAI = false;
        this.handleValidation();
    }

    handleRunAI() {
        this.isSpinner = true;
        this.showBtn = true;
        this.isAI = true;
        this.isSave = false;
        this.isCreateDeal = false;
        this.handleValidation();
    }

    handleValidation() {
        let idToEmailsMap = {};
        let quoteLineListtoUpdate = [];
        let quoteLineIdList = [];
        let selectedRowCount = 0;
        let processorQLIType = processorQuoteLineType.split(',');
        let errorCount = 0;
        let date = new Date().toJSON().slice(0, 10);
        this.requiredFields = mandatoryFields.split(':');
        let showSoftWarningSIPPandECAP = false;
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

                    if (this.data[i].Pricing_RegionQL_Nm__c == '' || this.data[i].Pricing_RegionQL_Nm__c == '--None--') {
                        validationMsg += 'Region must be selected';
                    }
                    quoteLineListtoUpdate.push(this.data[i]);
                    quoteLineIdList.push(this.data[i].Id);
                    if (this.isAI) {
                        if (!processorQLIType.includes(this.data[i].Pricing_Program_Type_Nm__c)) {
                            validationMsg += pricingAInotapplicableError;
                        }
                        else {
                            if (this.data[i].Pricing_Meet_Comp_Price_Amt__c === '0' || this.data[i].Pricing_Meet_Comp_Price_Amt__c === '' || this.data[i].Pricing_Meet_Comp_Price_Amt__c === undefined) {
                                error += 'My Deals Meet Comp Price \n';
                            }

                            /*if (this.data[i].Pricing_Tentative_ECAP_Price_Amt__c === '0' || this.data[i].Pricing_Tentative_ECAP_Price_Amt__c === '' || this.data[i].Pricing_Tentative_ECAP_Price_Amt__c === undefined) {
                                error += 'Tentative ECAP Price \n';
                            }*/
                        }
                    }
                    else {
                        if (this.isCreateDeal) {
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
                            let EcapPrice = this.data[i].Pricing_ECAP_Price_Amt__c == null || this.data[i].Pricing_ECAP_Price_Amt__c == undefined || this.data[i].Pricing_ECAP_Price_Amt__c == '' ? 0 : parseInt(this.data[i].Pricing_ECAP_Price_Amt__c);
                            let meetCompPrice = this.data[i].Pricing_Meet_Comp_Price_Amt__c == null || this.data[i].Pricing_Meet_Comp_Price_Amt__c == undefined || this.data[i].Pricing_Meet_Comp_Price_Amt__c == '' ? 0 : parseInt(this.data[i].Pricing_Meet_Comp_Price_Amt__c);
                            if ((this.data[i].Pricing_Program_Type_Nm__c == ccgQuoteLine) && (this.data[i].Pricing_SIPP_Cb__c == false) && (this.data[i].hasOwnProperty('Pricing_Market_Segment_values_Nm__c')) && (this.data[i].Pricing_Market_Segment_values_Nm__c == "Corp") && (this.data[i].Pricing_Change_Request_cb__c == false)) {
                                this.showSoftWarning = true;
                            }
                            if ((this.data[i].Pricing_Program_Type_Nm__c == ccgQuoteLine) && (((this.data[i].hasOwnProperty('Pricing_ECAP_Price_Amt__c')) && EcapPrice) < ((this.data[i].hasOwnProperty('Pricing_Meet_Comp_Price_Amt__c')) && meetCompPrice))) {
                                this.showSoftWarningApprovedECAP = true;
                            }
                            if (this.showSoftWarning || this.showSoftWarningApprovedECAP) {
                                showSoftWarningSIPPandECAP = true;
                            }

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
                        if ((this.data[i].Pricing_Tentative_ECAP_Price_Amt__c && this.data[i].Pricing_Tentative_ECAP_Price_Amt__c != undefined) && this.data[i].Pricing_Tentative_ECAP_Price_Amt__c <= 0) {
                            validationMsg += 'Tentative ECAP Price must be greater than $0.';
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
                        if (this.isCreateDeal && (this.data[i].Pricing_Backdate_Reason_Txt__c == undefined || this.data[i].Pricing_Backdate_Reason_Txt__c == '') && this.data[i].Pricing_Approved_Start_Date_Dt__c < date) {
                            error += 'Backdate Reason' + '\n';
                        }


                        if (this.isCreateDeal && this.data[i].Pricing_Approved_End_Date_Dt__c != undefined && this.data[i].Pricing_Approved_End_Date_Dt__c < date) {
                            validationMsg += pastDateError;
                        }

                        //To check for Intel Product if Application is CoSP, then Workload is mandatory for Data center Xeon CPU
                        if (this.isCreateDeal && this.data[i].Pricing_Server_Deal_Type_Nm__c == Cosp && this.data[i].Pricing_Program_Type_Nm__c == stdQuoteLine && (this.data[i].Pricing_Workload_Nm__c == undefined || this.data[i].Pricing_Workload_Nm__c == null) && this.data[i].Pricing_New_Change_Request_cb__c != true) {
                            validationMsg = validationMsg + MandatoryWorkloadErrorMessage;
                        }

                        //To check for Intel Product Workload field is Not Required while Creating a deal for QLI for Application as Non CoSP for Data Center Xeon CPU
                        if (this.isCreateDeal && this.data[i].Pricing_Server_Deal_Type_Nm__c != Cosp && this.data[i].Pricing_Program_Type_Nm__c == stdQuoteLine && (this.data[i].Pricing_Workload_Nm__c != undefined || this.data[i].Pricing_Workload_Nm__c != null) && this.data[i].Pricing_New_Change_Request_cb__c != true) {
                            validationMsg = validationMsg + NonMandatoryWorkloadErrorMessage;
                        }

                        if (this.isCreateDeal && this.data[i].Pricing_Billing_Start_Date_Dt__c != undefined && this.data[i].Pricing_Approved_Start_Date_Dt__c != undefined) {
                            var startDate = new Date(this.data[i].Pricing_Approved_Start_Date_Dt__c);
                            var billingDate = new Date(this.data[i].Pricing_Billing_Start_Date_Dt__c);
                            let difference = startDate - billingDate;
                            let noOfDaysBetweenDates = Math.ceil(difference / (1000 * 3600 * 24))
                            if (noOfDaysBetweenDates > allowedBillingDateBackDatingDays) {
                                validationMsg += billingQuarterError;
                            }
                        }

                        if ((this.data[i].Pricing_Reason_for_FeedBack_Txt__c != '' && this.data[i].Pricing_Reason_for_FeedBack_Txt__c != undefined) && !this.data[i].Pricing_Reason_for_FeedBack_Txt__c.match(latinCharCheck)) {
                            latinCharError += ' Reason for FeedBack ; ';
                        }

                        if ((this.data[i].Pricing_Additional_T_C_s_Txt__c != '' && this.data[i].Pricing_Additional_T_C_s_Txt__c != undefined) && !this.data[i].Pricing_Additional_T_C_s_Txt__c.match(latinCharCheck)) {
                            latinCharError += 'Additional T\'s & C\'s ; ';
                        }

                        if ((this.data[i].Pricing_Deal_Description__c != '' && this.data[i].Pricing_Deal_Description__c != undefined) && !this.data[i].Pricing_Deal_Description__c.match(latinCharCheck)) {
                            latinCharError += ' Deal Description ; ';
                        }

                        if (latinCharError.length > 0) {
                            validationMsg += latinErrorMsg + 'Please review following fields : ' + latinCharError.slice(0, -2) + '.';
                        }

                        if ((this.data[i].Pricing_Recommendation_FeedBack_Nm__c != '' && this.data[i].Pricing_Recommendation_FeedBack_Nm__c != undefined) && (this.data[i].Pricing_Recommendation_FeedBack_Nm__c.includes('Other') && (this.data[i].Pricing_Reason_for_FeedBack_Txt__c == undefined || this.data[i].Pricing_Reason_for_FeedBack_Txt__c == ''))) {
                            validationMsg += AIfeedbackOtherMsg;
                        }
                    }

                    if (error != '' || validationMsg != '') {
                        errorCount++;
                        var msgdisplay = this.isAI ? aiMeetCompErrorMsg : 'The following fields are required to create a Deal:';
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

            if (Object.keys(idToEmailsMap).length > 0) {
                this.handleAdditionalRecp(quoteLineIdList, quoteLineListtoUpdate, idToEmailsMap);
            }
            else {
                if (this.isAI) {
                    this.invokePricingAI(quoteLineIdList);
                } else {
                    if (this.isCreateDeal && showSoftWarningSIPPandECAP) {
                        this.softWarning_quoteLineListtoUpdate = quoteLineListtoUpdate;
                        this.softWarning_quoteLineIdList = quoteLineIdList;
                        this.showSoftWarningSIPPandECAP = true;

                    } else {
                        this.invokeSaveandDealCreation(quoteLineListtoUpdate, quoteLineIdList);
                    }
                }
            }
        }
    }

    handleAdditionalRecp(quoteLineIdList, quoteLineListtoUpdate, idToEmailsMap) {
        let apexErrorCount = 0;
        userHasValidRPMPermission({ quotelinelist: quoteLineListtoUpdate, idTOEmails: idToEmailsMap })
            .then(result => {
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
                    if (this.isAI) {
                        this.invokePricingAI(quoteLineIdList);
                    } else {
                        this.invokeSaveandDealCreation(quoteLineListtoUpdate, quoteLineIdList);
                    }
                } else {
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
            })
            .catch(error => {
                console.error('Error @ handleAdditionalRecp===>', JSON.stringify(error));
                this.isSpinner = false;
                this.showBtn = false;
            });

    }

    invokeSaveandDealCreation(quoteLineListtoUpdate, quoteLineIdList) {
        let apexErrorCount = 0;
        updateQuotelines({ quoteLineListtoUpdate: quoteLineListtoUpdate, parentId: quoteLineIdList, isCreateDeal: this.isCreateDeal, isUpdateDeal: false })
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
                        this.feedBackOptions.length = 0;
                        this.regionQLOptions.length = 0;
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

    invokePricingAI(quoteLineIdList) {
        makeCallout({ quoteLineId: quoteLineIdList })
            .then(result => {
                for (let i = 0; i < result.length; i++) {
                    let respData = JSON.parse(result[i]);
                    if (respData.message != null || respData.message != undefined) {
                        if (respData.quoteLineNumber == '') {
                            const toastMessageErrorAI = new ShowToastEvent({
                                title: 'Error!',
                                message: respData.message,
                                variant: 'error',
                                mode: 'sticky'
                            });
                            this.dispatchEvent(toastMessageErrorAI);
                            this.isSpinner = false;
                            this.showBtn = false;
                            break;
                        }
                        let element = this.data.find(ele => ele.Pricing_Quote_Line_Number__c === respData.quoteLineNumber);
                        element.isError = true;
                        element.errorMsg = respData.message;
                        this.data = [...this.data];
                    }
                    else {
                        let element = this.data.find(ele => ele.Pricing_Quote_Line_Number__c === respData.quoteLineNumber);
                        element["Pricing_Recommended_Price_Amt__c"] = respData.recommendedPrice;
                        element["Pricing_Price_Interval_Txt__c"] = respData.priceInterval;
                        element["Pricing_Discount_Pct__c"] = respData.discount * 100;
                        if (respData.warningMessage != '' && respData.warningMessage != undefined) {
                            element.isWarning = true;
                            element.errorMsg = respData.warningMessage;
                        }
                        if (this.isAutoAI || this.isClient) {
                            element["Pricing_ECAP_Price_Amt__c"] = Math.round(respData.recommendedPrice);
                        }
                        this.data = [...this.data];
                    }
                }
                this.isSpinner = false;
                this.showBtn = false;
            })
            .catch(error => {
                this.error = error;
                console.error('Error @ invokePricingAI ===>', error);
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

    handleRegionQL(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_RegionQL_Nm__c = event.target.value;
        this.data = [...this.data];
    }

    handleAdditionalTC(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Additional_T_C_s_Txt__c = event.target.value;
        this.data = [...this.data];
    }

    handlePricingManager(event) {
        let element = this.data.find(ele => ele.Id === event.target.dataset.id);
        element.Pricing_Manager__c = event.target.value;
        this.data = [...this.data];
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

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Worklaod })
    workloadpicklistvalue({ error, data }) {
        if (data) {
            data.values.forEach(element => {
                this.workloadpicklistOptions.push({ label: element.label, value: element.value });
            });
        } else if (error) {
            console.error('Error @ workloadpicklistvalue : ' + JSON.stringify(error));
        }
    }

    @wire(getObjectInfo, { objectApiName: Quote_Line })
    objectInfo;

    get recordTypeId() {
        // Returns a map of record type Ids
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find((rti) => rtis[rti].name === "Pricing_Tender_Quote_Line_Create");
    }

    workloadChange(event) {
        let workloadelement = this.data.find(ele => ele.Id === event.target.dataset.id);
        workloadelement.Pricing_Workload_Nm__c = event.target.value;
        this.data = [...this.data];
    }

    handleContinueSoftWarning() {
        this.showSoftWarning = false;
        this.showSoftWarningSIPPandECAP = false;
        this.showSoftWarningApprovedECAP = false;
        this.invokeSaveandDealCreation(this.softWarning_quoteLineListtoUpdate, this.softWarning_quoteLineIdList);
    }

}