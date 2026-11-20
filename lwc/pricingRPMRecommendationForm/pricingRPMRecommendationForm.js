import { LightningElement, api, wire, track } from 'lwc';
import getFormDetails from '@salesforce/apex/Pricing_FieldSetFormController.getFormFieldsAndSectionLabel';
import insertOutbound from '@salesforce/apex/Pricing_QuoteLineController.insertOutbound';
import readOnlyFields from '@salesforce/label/c.Pricing_Tender_QuoteLine_Read_Only_Fields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuoteLineDetails from '@salesforce/apex/Pricing_FieldSetFormController.getQuoteLineDetails';
import makeCallout from '@salesforce/apex/Pricing_PricingAI_Controller.makeCallout';
import isReadOnlyUser from '@salesforce/apex/Pricing_FieldSetFormController.isReadOnlyUser';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getQuoteLine from '@salesforce/apex/Pricing_QuoteLineController.getQuoteLine';
import getExcludedEndCustomerList from '@salesforce/apex/Pricing_QuoteLine_BulkDealController.getCustomSettingRecordsforExcludedList';
import accountToCIMIdMtdRec from '@salesforce/apex/Pricing_QuoteLine_BulkDealController.accountToCIMIdMappingMtdRec';
import qlSaveMsg from '@salesforce/label/c.Pricing_Tender_QuoteLine_Save_Message';
import qlMyDealsMsg from '@salesforce/label/c.Pricing_Tender_QuoteLine_MyDeals_Message';
import getAIErrorMsg from '@salesforce/label/c.Pricing_GetAI_Error_Message';
import writeInProduct from '@salesforce/label/c.Pricing_Write_In_Product';
import aiMeetCompErrorMsg from '@salesforce/label/c.Pricing_GetAI_MeetComp_Error_Message';
import createDealButton from '@salesforce/label/c.Pricing_Send_Request_MD_Button_Label';
import updateDealButton from '@salesforce/label/c.Pricing_Update_Deal_MD_button_label';
import runAIButton from '@salesforce/label/c.Pricing_RunAI_Button';
import saveButton from '@salesforce/label/c.Pricing_Save_Button_Label';
import getAIDateLabels from '@salesforce/label/c.Pricing_GetAI_Date_FieldLabel_Values';
import userId from '@salesforce/user/Id';
import processorQuoteLineType from '@salesforce/label/c.Pricing_Tender_Processors_Quote_Line_Type';
import wonStatus from '@salesforce/label/c.Pricing_Tender_QuoteLine_Status_Won';
import daysIfNoAccountPresentInMtd from '@salesforce/label/c.Pricing_NoOfDays_NotPresent_CIMIdMtd';
import getAPIMessageValue from '@salesforce/label/c.Pricing_GetAIValues_Message';
import programType from '@salesforce/label/c.Pricing_TenderProgramTypeForMeetCompAutoPopulate';
import application from '@salesforce/label/c.Pricing_TenderApplicationForMeetcompAutoPopulate';
import tentaticeEcapVal from '@salesforce/label/c.Pricing_TentaticeEcapValue_AutoAI';
import standardQuoteLine from '@salesforce/label/c.Pricing_Tender_Standard_QuoteLine';
import Quantity from '@salesforce/label/c.Pricing_Quantity';
import ccgQuoteLine from '@salesforce/label/c.Pricing_Tender_CCG_Quote';
import nicQuoteLine from '@salesforce/label/c.Pricing_Tender_NIC_Quote';
import ssdQuoteLine from '@salesforce/label/c.Pricing_Tender_SSD_Quote';
import pmemQuoteLine from '@salesforce/label/c.Pricing_Tender_PMem_Quote';
import gpuQuoteLine from '@salesforce/label/c.Pricing_Tender_DataCenter_GPU';
import svdQuoteLine from '@salesforce/label/c.Pricing_Tender_Small_Volume_Quote';
import LightningAlert from 'lightning/alert';
import payableQuantityErrorMessage from '@salesforce/label/c.Pricing_Tender_QuoteLine_Payable_Quantity_Error';
import restrictedAccountMethod from '@salesforce/apex/Pricing_QuoteLineCloneController.restrictedAccountMethod';
import softWarningForLargeEnterpriseLabel from '@salesforce/label/c.Pricing_Tender_Soft_Warning_for_Large_Enterprise';
import softWarningForLargeEnterpriseApprovedECAPLabel from '@salesforce/label/c.Pricing_Tender_Approved_ECAP';
import isActive from '@salesforce/apex/Pricing_PricingAI_BulkController.isPricingAIEnabled';

const TITLE_TEXT = 'Success!';
const MSG_TEXT = qlMyDealsMsg; //'Quote Line details has been sent to My Deals.';
const VAR_TEXT = 'success';
const MODE = 'dismissable';
const MSG_TEXT_Save = qlSaveMsg; //'Quote Line was saved.';

const modalOpenValue = false;
const isRefreshAccordionRPM = true;

const TITLE_TEXTERROR = 'Error!';
const VAR_TEXTERROR = 'error';
const MODE_ERROR = 'sticky';

const TITLE_TEXTAIERROR = 'Error!';
const VAR_TEXTAIERROR = 'error';
const MODE_AIERROR = 'dismissable';
const WP_AIERRORMSG = getAIErrorMsg;//'AI model cannot be run if Write In Product is used.';

export default class PricingRPMRecommendationForm extends NavigationMixin(LightningElement) {

    @api recordId;
    @track formValues;
    @track isModalOpen = true;
    @track loadSpinner = true;
    @track load = true;
    @track disableButton = false;
    @track isCreateDeal = true;
    @track isSave = false;
    @track isSubmitSpinner = false;
    @track action;
    @track isWriteInProduct = false;
    @track isAI = false;
    @track dealButtonLabel = createDealButton;
    @track continueButtonLabel = '';
    @track isDealButtonClicked = false;
    @track saveLabel = saveButton;
    @track aIButtonLabel = runAIButton;
    @api isnotquotepage;
    @api recordid;
    @track quoteLineId;
    @track isReadOnlyForm = false;
    @track recommendedPrice;
    @track priceInterval;
    @track pricingDiscount;
    @track recommendedPriceAPIField;
    @track priceIntervalAPIField;
    @track pricingDiscountAPIField;
    @track meetCompValue;
    @track errorMsg = '';
    @track isDPMLegalFianance = false;
    @track isRunAIVisible = false;
    @track productName;

    @track isDateValue = false;
    @track appPriceStartDate;
    @track appPriceEndDate;
    @track appPriceStartDateDup;
    @track appPriceEndDateDup;
    @track billingStartDate;
    @track billingEndDate;
    @track qlPriceEndDate;
    @track revPriceStartDate;
    @track revPriceStartDateDup;
    @track quoteId;
    @track isDraftQL = false;
    @track tentativeEcapPrice;
    @track meetCompPriceLabel;
    @track tentativeEcapPriceLabel;
    @track isWonCR = false;
    @track isAutoAI = false;
    @track runAI = false;
    @track date;
    @track dateBeforeSixMonth;
    @track dateBeforeSixMonthFromToday;
    @track dateAfterYear;
    @track getAIMessage = false;
    @track getAPIMessageValues;
    @track endCustomerList = [];
    @track isBillingStartDate = false;
    accToDaysMtdRec = new Map();
    @track dateWithoutTime;
    @track accId;
    @track count;
    @track isClient = false;
    wonChangeRequest;
    isRestrictedAccount;
    quoteAccountId;
    quotePricingRegion;
    quoteLineDataResult;
    softWarningForLargeEnterprise = softWarningForLargeEnterpriseLabel;
    softWarningForLargeEnterpriseApprovedECAP = softWarningForLargeEnterpriseApprovedECAPLabel;
    isSoftWarningModalVisible = false;
    isSoftWarningModalVisibleApprovedECAP = false;
    isSoftWarningModalVisibleApprovedECAPAndSIPPError = false;
    pricingAIEnabled;

    connectedCallback() {

        isActive({functionalityName : 'Pricing_AI'}).then(result => {
            this.pricingAIEnabled = result;
        });

        if (this.isnotquotepage === 'true') {
            this.quoteLineId = this.recordid;
        }
        else {
            this.quoteLineId = this.recordId;
        }
        isReadOnlyUser()
            .then(result => {
                this.isDPMLegalFianance = result;
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });

        getExcludedEndCustomerList()
            .then(result => {
                this.endCustomerList = result;
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });

        getQuoteLine({ quoteLineId: this.quoteLineId })
            .then(result => {
                this.quoteLineDataResult = result;                
                this.quoteAccountId = result.SBQQ__Quote__r.SBQQ__Account__c;
                this.quotePricingRegion = result.SBQQ__Quote__r.Pricing_Region_Nm__c;
                this.wonChangeRequest = (result.Pricing_New_Change_Request_cb__c && result.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c == wonStatus) ? true : false;
                this.accId = 'Id_' + result.SBQQ__Quote__r.SBQQ__Account__c;
                if (result.Pricing_Change_Request_cb__c == true && result.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c == wonStatus) {
                    this.isWonCR = true;
                }
                //standardQuoteLine has value of Data Center Xeon® CPU
                //Quantity has value of 100 
                if (!result.Pricing_Change_Request_cb__c && result.Pricing_Product_Nm__r.Name != writeInProduct && programType.split(',').includes(result.Pricing_Program_Type_Nm__c) && application.split(',').includes(result.SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c) &&
                    (result.Pricing_Program_Type_Nm__c != standardQuoteLine || (result.Pricing_Program_Type_Nm__c == standardQuoteLine && result.Pricing_Unit_Qty__c <= Quantity && (result.SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c != 'CSP' ||
                        (result.SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c == 'CSP' && !this.endCustomerList.includes(result.Pricing_EndCustomer_Nm__c)))))) {

                    this.isAutoAI = true;
                    this.disableButton = true;
                    this.getAPIMessageValues = getAPIMessageValue;
                    this.getAIMessage = true;
                    if ((result.Pricing_Tentative_ECAP_Price_Amt__c === '' || result.Pricing_Tentative_ECAP_Price_Amt__c === undefined) && (result.Pricing_Meet_Comp_Price_Amt__c != '' && result.Pricing_Meet_Comp_Price_Amt__c != undefined)) {
                        this.runAI = true;
                    }
                }
                if (!result.Pricing_Change_Request_cb__c) {
                    this.isBillingStartDate = true;
                }
                if (!result.Pricing_Change_Request_cb__c && result.Pricing_Program_Type_Nm__c == ccgQuoteLine && (result.Pricing_Tentative_ECAP_Price_Amt__c === '' || result.Pricing_Tentative_ECAP_Price_Amt__c === undefined)) {
                    this.isClient = true;
                    this.runAI = true;
                }

                var today = new Date();
                this.date = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();

                this.dateAfterYear = today.getFullYear() + 1 + '-' + (today.getMonth() + 1) + '-' + today.getDate();
                
                var priorDate = new Date(new Date().setDate(today.getDate() - daysIfNoAccountPresentInMtd));
                this.dateBeforeSixMonthFromToday = priorDate.getFullYear() + '-' + (priorDate.getMonth() + 1) + '-' + priorDate.getDate();

                let approveStartDate = new Date(result.Pricing_Approved_Start_Date_Dt__c);
                // Subtract 180 days from the approveStartDate
                let approveStartDatePast = new Date(approveStartDate);
                approveStartDatePast.setDate(approveStartDate.getDate() - daysIfNoAccountPresentInMtd);
                this.dateBeforeSixMonth = approveStartDatePast.getFullYear() + '-' + (approveStartDatePast.getMonth() + 1) + '-' + approveStartDatePast.getDate();
                this.getMetadataRecords();
            });
        this.getFieldSetFormDetails();

    }

    getMetadataRecords() {
        accountToCIMIdMtdRec()
            .then(result => {
                this.accToDaysMtdRec = [];
                this.accToDaysMtdRec = result;
                for (var key in result) {
                    if (key == this.accId && (result[key] != undefined || result[key] != null)) {
                        this.count = result[key];
                    }
                }
            })
            .catch(error => {
                console.error('Error @ getMetadataRecords ---->:' + JSON.stringify(error));
            });
    }
    getFieldSetFormDetails() {
        getFormDetails({ recordId: this.quoteLineId })
            .then(result => {
                let formDetails = JSON.parse(JSON.stringify(result));
                var fieldList = readOnlyFields;
                let fieldArray = fieldList.split(',');
                for (var i = 0; i < formDetails.length; i++) {
                    for (var j = 0; j < formDetails[i].Fields.length; j++) {
                        if (fieldArray.includes(formDetails[i].Fields[j]["APIName"])) {
                            formDetails[i].Fields[j]["isInput"] = false;
                        }
                        if (formDetails[i].Fields[j]["APIName"] == 'Pricing_Revised_Pricing_Start_Date_dt__c' && this.isWonCR == false) {
                            formDetails[i].Fields[j]["isInput"] = false;
                        }
                        if (formDetails[i].Fields[j]["APIName"] == 'Pricing_Recommended_Price_Amt__c') {
                            this.recommendedPriceAPIField = formDetails[i].Fields[j]["APIName"];
                            formDetails[i].Fields[j]["Type"] = 'NUMBER';
                        }
                        if (formDetails[i].Fields[j]["APIName"] == 'Pricing_Price_Interval_Txt__c') {
                            this.priceIntervalAPIField = formDetails[i].Fields[j]["APIName"];
                        }
                        if (formDetails[i].Fields[j]["APIName"] == 'Pricing_Discount_Pct__c') {
                            this.pricingDiscountAPIField = formDetails[i].Fields[j]["APIName"];
                        }
                        if (formDetails[i].Fields[j]["APIName"] == 'Pricing_Payable_Quantity__c') {
                            this.checkRestrictedAccount();
                        }
                    }
                }
                formDetails[0]['sectionLabel'] = 'FisrtBlock';
                this.formValues = formDetails;

                if (this.pricingAIEnabled == true && this.runAI) {
                    this.invokePricingAI();
                } else {
                    this.getQuotelineData();
                }
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.loadSpinner = false;
                this.isReadOnlyForm = true;
            });
    }

    checkRestrictedAccount() {
        restrictedAccountMethod({ recordId: this.quoteAccountId, pricingRegion: this.quotePricingRegion })
            .then(result => {
                this.isRestrictedAccount = result;
                for (var i = 0; i < this.formValues.length; i++) {
                    for (var j = 0; j < this.formValues[i].Fields.length; j++) {
                        if (this.formValues[i].Fields[j]["APIName"] == 'Pricing_Payable_Quantity__c') {
                            if (this.wonChangeRequest == true) {
                                if (this.isRestrictedAccount == true) {
                                    this.formValues[i].Fields[j]["doubleFieldValue"] = this.quoteLineDataResult.Pricing_Payable_Quantity__c; 
                                }
                                else if (this.isRestrictedAccount == false) {
                                    this.formValues[i].Fields[j]["fieldDisabled"] = true;
                                    this.formValues[i].Fields[j]["doubleFieldValue"] = this.quoteLineDataResult.Pricing_Approved_Unit_Qty__c;
                                }
                            }
                            else if (this.wonChangeRequest == false) {
                                this.formValues[i].Fields[j]["fieldDisabled"] = true;
                            }
                        }
                    }
                }
            });
    }

    getQuotelineData() {
        getQuoteLineDetails({ quoteLineId: this.quoteLineId })
            .then(result => {
                getRecordNotifyChange([{ recordId: this.quoteLineId }]);

                if (result.Pricing_Status_Nm__c === 'Draft') {
                    this.isDraftQL = true;
                } else if (result.Pricing_Status_Nm__c === 'Pending Further Intel Review' && (result.Pricing_Integration_Status_Nm__c !== 'Pending' && result.Pricing_Integration_Status_Nm__c !== 'InProcess' && result.Pricing_Deal_RFQ_Status_Nm__c != 'Submitted')) {
                    this.isReadOnlyForm = false;
                } else {
                    this.isReadOnlyForm = true;
                }

                this.isWriteInProduct =
                    ((result.Pricing_Reference_Quote_Line_Nbr__c === undefined
                        || (result.Pricing_Reference_Quote_Line_Nbr__c != undefined
                            && (result.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Deal_RFQ_Id__c != undefined
                                || result.Pricing_Reference_Quote_Line_Nbr__r.SBQQ__ProductName__c != result.SBQQ__ProductName__c)
                        )
                    )) ? false : true;

                //Check if DPG Quoteline or Change request Quoteline to show Run AI button
                var processorQT = processorQuoteLineType;
                var processorProgramType = processorQT.split(',');
                if (!processorProgramType.includes(result.Pricing_Program_Type_Nm__c) || result.Pricing_Change_Request_cb__c == true || result.Pricing_New_Change_Request_cb__c == true) {
                    this.isRunAIVisible = true;
                }

                if ((result.Pricing_Integration_Status_Nm__c === 'Error' && (result.Pricing_Deal_RFQ_Id__c === undefined && result.Pricing_Deal_RFQ_Status_Nm__c === undefined)) ||
                    (result.Pricing_Integration_Status_Nm__c === undefined && (result.Pricing_Reference_Quote_Line_Nbr__c === undefined || (result.Pricing_Reference_Quote_Line_Nbr__c !== undefined && result.Pricing_Reference_Quote_Line_Nbr__r.SBQQ__ProductName__c != result.SBQQ__ProductName__c)))) {
                    this.dealButtonLabel = createDealButton;//'Create Deal';
                    this.continueButtonLabel = 'Continue';// and '+createDealButton;
                    this.isCreateDeal = true;
                }
                else if ((result.Pricing_Integration_Status_Nm__c === 'Error' && (result.Pricing_Deal_RFQ_Status_Nm__c === undefined && result.Pricing_Reference_Quote_Line_Nbr__c !== '')) ||
                    (result.Pricing_Deal_RFQ_Status_Nm__c === 'Requested' && result.Pricing_Deal_RFQ_Id__c !== '') ||
                    (result.Pricing_Integration_Status_Nm__c === undefined && result.Pricing_Reference_Quote_Line_Nbr__c !== '')) {
                    this.dealButtonLabel = updateDealButton//'Update Deal';
                    this.continueButtonLabel = 'Continue';// and '+updateDealButton;
                    this.isCreateDeal = false;
                }

                this.meetCompValue = this.isClient ? result.Pricing_Req_Discounted_Unit_Price__c : result.Pricing_Meet_Comp_Price_Amt__c;
                this.tentativeEcapPrice = (this.isAutoAI || this.isClient) && (result.Pricing_Tentative_ECAP_Price_Amt__c === '' || result.Pricing_Tentative_ECAP_Price_Amt__c === undefined) ? tentaticeEcapVal : result.Pricing_Tentative_ECAP_Price_Amt__c;
                this.productName = result.Pricing_Other_Product_Nm__c;
                this.quoteId = result.SBQQ__Quote__c;

                for (var i = 0; i < this.formValues.length; i++) {
                    for (var j = 0; j < this.formValues[i].Fields.length; j++) {
                        if (this.formValues[i].Fields[j]["APIName"] == 'Pricing_Approved_Start_Date_Dt__c') {
                            this.formValues[i].Fields[j]["fieldValue"] = this.isAutoAI && (result.Pricing_Approved_Start_Date_Dt__c === '' || result.Pricing_Approved_Start_Date_Dt__c === undefined) ? this.date: result.Pricing_Approved_Start_Date_Dt__c;
                        }
                        if (this.formValues[i].Fields[j]["APIName"] == 'Pricing_Approved_End_Date_Dt__c') {
                            this.formValues[i].Fields[j]["fieldValue"] = this.isAutoAI && (result.Pricing_Approved_End_Date_Dt__c === '' || result.Pricing_Approved_End_Date_Dt__c === undefined) ? this.dateAfterYear : result.Pricing_Approved_End_Date_Dt__c;
                        }
                        if (this.formValues[i].Fields[j]["APIName"] == 'Pricing_Approved_End_Date_Dup_Dt__c') {
                            this.formValues[i].Fields[j]["fieldValue"] = result.Pricing_Approved_End_Date_Dup_Dt__c;
                        }
                        if (this.formValues[i].Fields[j]["APIName"] == 'Pricing_Approved_Start_Date_Dup_Dt__c') {
                            this.formValues[i].Fields[j]["fieldValue"] = result.Pricing_Approved_Start_Date_Dup_Dt__c;
                        }
                        if (this.formValues[i].Fields[j]["APIName"] == 'Pricing_Billing_End_Date_Dt__c') {
                            this.formValues[i].Fields[j]["fieldValue"] = this.isAutoAI && (result.Pricing_Billing_End_Date_Dt__c === '' || result.Pricing_Billing_End_Date_Dt__c === undefined) ? this.dateAfterYear : result.Pricing_Billing_End_Date_Dt__c;
                        }

                        if ((result.Pricing_Program_Type_Nm__c == nicQuoteLine || result.Pricing_Program_Type_Nm__c == ssdQuoteLine || result.Pricing_Program_Type_Nm__c == pmemQuoteLine || result.Pricing_Program_Type_Nm__c == gpuQuoteLine || result.Pricing_Program_Type_Nm__c == svdQuoteLine) && this.formValues[i].Fields[j]["APIName"] == 'Pricing_SDM_Fast_Track__c') {
                            this.formValues[i].Fields[j]["isInput"] = false;
                        }

                        if (this.formValues[i].Fields[j]["APIName"] == 'Pricing_Billing_Start_Date_Dt__c') {
                            if (this.count != undefined) {
                                var today = new Date();
                                var priorDate = new Date(new Date().setDate(today.getDate() - this.count));
                                this.dateWithoutTime = priorDate.getFullYear() + '-' + (priorDate.getMonth() + 1) + '-' + priorDate.getDate();

                                //approveStartDate - no of days from CIM Id metadata for Client QL type if metadata record has no of days configured.
                                var approvedStartDate = new Date(result.Pricing_Approved_Start_Date_Dt__c);
                                var approvedStartDatePast = new Date(approvedStartDate);
                                approvedStartDatePast.setDate(approvedStartDate.getDate() - this.count);
                                var dateBeforeApproveStartDate = approvedStartDatePast.getFullYear() + '-' + (approvedStartDatePast.getMonth() + 1) + '-' + approvedStartDatePast.getDate();

                                this.formValues[i].Fields[j]["fieldValue"] = (this.count != undefined && this.isAutoAI && (result.Pricing_Billing_Start_Date_Dt__c === '' || result.Pricing_Billing_Start_Date_Dt__c === undefined)) ? this.dateWithoutTime : this.isClient ? dateBeforeApproveStartDate : result.Pricing_Billing_Start_Date_Dt__c;
                            } else {

                                this.formValues[i].Fields[j]["fieldValue"] = (this.isAutoAI && (result.Pricing_Billing_Start_Date_Dt__c === '' || result.Pricing_Billing_Start_Date_Dt__c === undefined)) ? this.dateBeforeSixMonthFromToday : this.isClient ? this.dateBeforeSixMonth : result.Pricing_Billing_Start_Date_Dt__c;
                            }
                        }
                        if (this.formValues[i].Fields[j]["APIName"] == 'Pricing_End_Date_dt__c') {
                            this.formValues[i].Fields[j]["fieldValue"] = result.Pricing_End_Date_dt__c;
                        }
                        if (this.formValues[i].Fields[j]["APIName"] == 'Pricing_Revised_Pricing_Start_Date_dt__c') {
                            this.formValues[i].Fields[j]["fieldValue"] = result.Pricing_Revised_Pricing_Start_Date_dt__c;
                        }
                        if (this.formValues[i].Fields[j]["APIName"] == 'Pricing_Revised_Pricing_Start_Date_D_dt__c') {
                            this.formValues[i].Fields[j]["fieldValue"] = result.Pricing_Revised_Pricing_Start_Date_D_dt__c;
                        }
                        if (this.formValues[i].Fields[j]["APIName"] == 'Pricing_Meet_Comp_Price_Amt__c') {
                            this.meetCompPriceLabel = this.formValues[i].Fields[j]["Label"];
                        }

                        if (this.formValues[i].Fields[j]["APIName"] == 'Pricing_Tentative_ECAP_Price_Amt__c') {
                            this.tentativeEcapPriceLabel = this.formValues[i].Fields[j]["Label"];
                        }
                    }
                }
                if (this.isAutoAI || this.isClient) {
                    const autoAIFields = this.template.querySelectorAll('lightning-input-field');
                    if (autoAIFields) {
                        autoAIFields.forEach(field => {
                            if (field.fieldName === 'Pricing_Tentative_ECAP_Price_Amt__c') {
                                field.value = this.tentativeEcapPrice;
                            }
                            if (field.fieldName === 'Pricing_ECAP_Price_Amt__c') {
                                field.value = result.Pricing_ECAP_Price_Amt__c === '' || result.Pricing_ECAP_Price_Amt__c === undefined || result.Pricing_ECAP_Price_Amt__c === null ? Math.round(this.recommendedPrice) : result.Pricing_ECAP_Price_Amt__c;
                            }
                            if (field.fieldName === 'Pricing_Meet_Comp_Price_Amt__c' && !this.isAutoAI) {
                                field.value = result.Pricing_Meet_Comp_Price_Amt__c === '' || result.Pricing_Meet_Comp_Price_Amt__c === undefined || result.Pricing_Meet_Comp_Price_Amt__c === null ? this.meetCompValue : result.Pricing_Meet_Comp_Price_Amt__c;
                            }
                        });
                    }
                }
                this.getAIMessage = false;
                this.disableButton = false;
                this.loadSpinner = false;
            });
    }

    handleChange(event) {
        if (event.target.fieldName === 'Pricing_Meet_Comp_Price_Amt__c') {
            this.meetCompValue = event.target.value;
        }

        if (event.target.fieldName === 'Pricing_Tentative_ECAP_Price_Amt__c') {
            this.tentativeEcapPrice = event.target.value;
        }

        if (event.target.fieldName === 'Pricing_Other_Product_Nm__c') {
            this.productName = event.target.value;
        }
        if (event.target.fieldName === 'Pricing_Approved_Unit_Qty__c' && this.wonChangeRequest == true && this.isRestrictedAccount == false) {
            this.template.querySelectorAll('lightning-input-field').forEach(field => {
                if (field.fieldName == 'Pricing_Payable_Quantity__c') {
                    field.value = event.target.value;
                }
            });
        }
    }

    handleInputChange(event) {
        let dateLabels = getAIDateLabels.split(',');
        if (event.target.label === dateLabels[0]) {
            this.appPriceStartDate = event.target.value;
        }
        if (event.target.label === dateLabels[1]) {
            this.appPriceEndDate = event.target.value;
        }
        if (event.target.label === dateLabels[2]) {
            this.revPriceStartDate = event.target.value;
        }
        if (event.target.label === dateLabels[3]) {
            this.billingStartDate = event.target.value;
        }
        if (event.target.label === dateLabels[4]) {
            this.billingEndDate = event.target.value;
        }
        if (event.target.label === dateLabels[5]) {
            this.qlPriceEndDate = event.target.value;
        }
        const dateFields = this.template.querySelectorAll('lightning-input-field');
        if (dateFields) {
            dateFields.forEach(field => {
                if (field.fieldName === 'Pricing_Approved_Start_Date_Dt__c') {
                    field.value = this.appPriceStartDate;
                }
                if (field.fieldName === 'Pricing_Approved_End_Date_Dt__c') {
                    field.value = this.appPriceEndDate;
                }
                if (field.fieldName === 'Pricing_Approved_End_Date_Dup_Dt__c') {
                    field.value = this.appPriceEndDate;
                }
                if (field.fieldName === 'Pricing_Approved_Start_Date_Dup_Dt__c') {
                    field.value = this.appPriceStartDate;
                }
                if (field.fieldName === 'Pricing_Billing_End_Date_Dt__c') {
                    field.value = this.billingEndDate;
                }
                if (field.fieldName === 'Pricing_Billing_Start_Date_Dt__c') {
                    field.value = this.billingStartDate;
                }
                if (field.fieldName === 'Pricing_End_Date_dt__c') {
                    field.value = this.qlPriceEndDate;
                }
                if (field.fieldName === 'Pricing_Revised_Pricing_Start_Date_dt__c') {
                    field.value = this.revPriceStartDate;
                }
                if (field.fieldName === 'Pricing_Revised_Pricing_Start_Date_D_dt__c') {
                    field.value = this.revPriceStartDate;
                }
            });
        }

    }

    handleClick(event) {
        let childComp = (event.target.firstElementChild === null) ? event.target : event.target.firstElementChild.firstElementChild;
        childComp.iconName = (childComp.iconName === 'utility:chevronright') ? 'utility:chevrondown' : 'utility:chevronright';
    }

    handleLoad() {
        this.load = false;
        const pricingAIFields = this.template.querySelectorAll('lightning-input-field');
        if (pricingAIFields) {
            pricingAIFields.forEach(field => {
                if (field.fieldName === this.recommendedPriceAPIField) {
                    field.disabled = true;
                }
                if (field.fieldName === this.priceIntervalAPIField) {
                    field.disabled = true;
                }
                if (field.fieldName === this.pricingDiscountAPIField) {
                    field.disabled = true;
                }
            });
        }
    }

    handleQLSelect(event) {
        this.quoteLineId = event.detail;
    }

    handleSave() {
        this.isSave = true;
        this.isAI = false;
        this.isDealButtonClicked = false;
    }

    handleDealClick() {
        this.isDealButtonClicked = true;
        this.isSave = false;
        this.isAI = false;
    }

    get spinnerStyle() {
        if (this.isnotquotepage !== 'true') {
            return 'spinnerStyle';
        } else {
            return 'loadingSpinner';
        }
    }

    handleAI() {
        this.isAI = true;
        this.isSave = false;
        this.isDealButtonClicked = false;
        this.errorMsg = '';
    }

    handleSuccess() {
        if (this.isDealButtonClicked === true) {
            if (this.isCreateDeal === true) {
                this.action = 'Create';
                this.insertOutboundMessage();
            } else {
                this.action = 'Update';
                this.insertOutboundMessage();
            }
        }

        if (this.isSave === true) {
            const toastMessageSave = new ShowToastEvent({
                title: TITLE_TEXT,
                message: MSG_TEXT_Save,
                variant: VAR_TEXT,
                mode: MODE
            });
            this.dispatchEvent(toastMessageSave);

            const refreshAccordion = new CustomEvent("RPMRefreshAccordionEvent", { detail: { isRefreshAccordionRPM } },);
            this.dispatchEvent(refreshAccordion);
            this.saveLabel = saveButton;//'Save';

            const closeModalEvent = new CustomEvent("RPMModalOpenEvent", { detail: { modalOpenValue } },);
            this.dispatchEvent(closeModalEvent);

            this.isSubmitSpinner = false;
            this.disableButton = false;
            this.errorMsg = '';
        }
        if (this.isAI === true) {

            /*if ((this.meetCompValue === '0' || this.meetCompValue === '' || this.meetCompValue === undefined) && (this.tentativeEcapPrice === '0' || this.tentativeEcapPrice === '' || this.tentativeEcapPrice === undefined)) {
                this.errorMsg = aiMeetCompErrorMsg + ' ' + this.meetCompPriceLabel;// + ', ' + this.tentativeEcapPriceLabel;
                this.isSubmitSpinner = false;
                this.disableButton = false;
                this.aIButtonLabel = runAIButton;
            }*/

            if (this.meetCompValue === '0' || this.meetCompValue === '' || this.meetCompValue === undefined) {
                this.errorMsg = aiMeetCompErrorMsg + ' ' + this.meetCompPriceLabel;
                this.isSubmitSpinner = false;
                this.disableButton = false;
                this.aIButtonLabel = runAIButton;
            }

            /*else if (this.tentativeEcapPrice === '0' || this.tentativeEcapPrice === '' || this.tentativeEcapPrice === undefined) {
                this.errorMsg = aiMeetCompErrorMsg;// + ' ' + this.tentativeEcapPriceLabel;
                this.isSubmitSpinner = false;
                this.disableButton = false;
                this.aIButtonLabel = runAIButton;
            }*/

            if (this.productName !== '' && this.productName !== undefined/*'Write In Product'*/) {
                const toastMessageErrorWPAI = new ShowToastEvent({
                    title: TITLE_TEXTAIERROR,
                    message: WP_AIERRORMSG,
                    variant: VAR_TEXTAIERROR,
                    mode: MODE_AIERROR
                });
                this.dispatchEvent(toastMessageErrorWPAI);
                this.isSubmitSpinner = false;
                this.disableButton = false;
                this.aIButtonLabel = runAIButton;
            }

            if (this.errorMsg === '') {
                if (this.productName === '' || this.productName === undefined) {
                    this.invokePricingAI();
                }
            }
        }

    }

    handleError() {
        this.saveLabel = saveButton;
        this.aIButtonLabel = runAIButton;
        this.isSubmitSpinner = false;
        this.disableButton = false;
        this.dealButtonLabel = this.isCreateDeal ? createDealButton/*'Create Deal'*/ : updateDealButton;//'Update Deal';
        const scroll = this.template.querySelector('lightning-messages');
        scroll.scrollIntoView();
    }

    closeSoftWarningForLargeEnterpriseModal() {
        this.isSoftWarningModalVisible = false;
        this.isSoftWarningModalVisibleApprovedECAP = false;
        this.isSoftWarningModalVisibleApprovedECAPAndSIPPError = false;
    }

    submitEventData;
    handleContinueSoftWarning() {
        this.isSoftWarningModalVisible = false;
        this.isSoftWarningModalVisibleApprovedECAP = false;
        this.isSoftWarningModalVisibleApprovedECAPAndSIPPError = false;
        this.submitRecord(this.submitEventData);
    }

    handleSubmit(event) {
        event.preventDefault();
        let isError = false;
        const field = event.detail.fields;
        if (field.Pricing_Approved_Unit_Qty__c != undefined && (field.Pricing_Payable_Quantity__c > field.Pricing_Approved_Unit_Qty__c)) {
            this.disableButton = true;
            this.isSubmitSpinner = true;
            isError = this.payableQuantityAlert(payableQuantityErrorMessage, 'error');
        }
        if (this.isDealButtonClicked === true && (this.quoteLineDataResult.Pricing_Program_Type_Nm__c == ccgQuoteLine) && (Number(field.Pricing_ECAP_Price_Amt__c) < Number(field.Pricing_Meet_Comp_Price_Amt__c))) {
            this.isSoftWarningModalVisibleApprovedECAP = true;
            this.submitEventData = field;
        }
        if (this.isDealButtonClicked === true && (this.quoteLineDataResult.Pricing_Program_Type_Nm__c == ccgQuoteLine) && (this.quoteLineDataResult.Pricing_SIPP_Cb__c == false) && (this.quoteLineDataResult.hasOwnProperty('Pricing_Market_Segment_values_Nm__c')) && (this.quoteLineDataResult.Pricing_Market_Segment_values_Nm__c == "Corp") && (this.quoteLineDataResult.Pricing_Change_Request_cb__c == false) && (field.Pricing_Form_Factor_Nm__c == "Notebook")) {
            this.isSoftWarningModalVisible = true;
            this.submitEventData = field;
        }
        if (this.isSoftWarningModalVisible || this.isSoftWarningModalVisibleApprovedECAP) {
            this.isSoftWarningModalVisibleApprovedECAPAndSIPPError = true;
            this.submitEventData = field;
        }
        else if(isError == false){
            this.submitRecord(field);
        }
    }

    submitRecord(field) {
        this.saveLabel = this.isSave ? 'Saving...' : saveButton;
        this.aIButtonLabel = this.isAI ? 'Saving...' : runAIButton;
        this.disableButton = true;
        this.isSubmitSpinner = true;
        if (this.isDealButtonClicked === true) {
            this.dealButtonLabel = 'Saving...';
            field.Pricing_Manager__c = userId;
        }
        this.template.querySelector('lightning-record-edit-form').submit(field);
    }

    payableQuantityAlert(message, theme) {
        LightningAlert.open({
            message: message,
            theme: theme
        }).then(() => {
            this.isSubmitSpinner = false;
            this.disableButton = false;
        });
        return true;
    }

    handleCancel() {
        this.isModalOpen = false;
        const closeModalEvent = new CustomEvent("RPMModalOpenEvent", { detail: { modalOpenValue } },);
        this.dispatchEvent(closeModalEvent);
        const handleChangeURLEvent = new CustomEvent("changeurlevent", { detail: { modalOpenValue } },);
        this.dispatchEvent(handleChangeURLEvent);
    }

    insertOutboundMessage() {
        insertOutbound({ parentId: this.quoteLineId, action: this.action })
            .then(result => {
                if (result == 'Success') {
                    if (this.isnotquotepage !== 'true') {
                        this.isModalOpen = false;
                        const refreshAccordionIntegration = new CustomEvent("RPMRefreshAccordionEvent", { detail: { isRefreshAccordionRPM } },);
                        this.dispatchEvent(refreshAccordionIntegration);
                    } else if (this.isnotquotepage === 'true') {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.quoteId,
                                objectApiName: 'SBQQ__Quote__c',
                                actionName: 'view'
                            },
                        });
                    }
                    const toastMessage = new ShowToastEvent({
                        title: TITLE_TEXT,
                        message: MSG_TEXT,
                        variant: VAR_TEXT,
                        mode: MODE
                    });
                    this.dispatchEvent(toastMessage);

                    const closeModalEventIntegration = new CustomEvent("RPMModalOpenEvent", { detail: { modalOpenValue } },);
                    this.dispatchEvent(closeModalEventIntegration);
                    this.getQuotelineData();

                } else {
                    this.isModalOpen = true;
                    const toastMessage = new ShowToastEvent({
                        title: TITLE_TEXTERROR,
                        message: result,
                        variant: VAR_TEXTERROR,
                        mode: MODE_ERROR
                    });
                    this.dispatchEvent(toastMessage);
                }

                this.isSubmitSpinner = false;
                this.disableButton = false;
                this.errorMsg = '';
                this.dealButtonLabel = this.isCreateDeal ? createDealButton/*'Create Deal'*/ : updateDealButton;//'Update Deal';
            })
            .catch(error => {
                this.error = error;
                const toastMessageExcepion = new ShowToastEvent({
                    title: TITLE_TEXTAIERROR,
                    message: 'Error processing response from Crete Deal. Please check the request and try again.',
                    variant: VAR_TEXTAIERROR,
                    mode: 'sticky'
                });
                this.dispatchEvent(toastMessageExcepion);
                this.isSubmitSpinner = false;
                this.disableButton = false;
                this.errorMsg = '';
                this.dealButtonLabel = this.isCreateDeal ? createDealButton : updateDealButton;
            });
    }

    invokePricingAI() {
        makeCallout({ quoteLineId: this.quoteLineId })
            .then(result => {
                if (result != null && result != undefined && result.length > 0) {
                    let errRespData = JSON.parse(result[0]);
                    if (errRespData.message != null || errRespData.message != undefined) {
                        const toastMessageErrorAI = new ShowToastEvent({
                            title: TITLE_TEXTAIERROR,
                            message: errRespData.message,
                            variant: VAR_TEXTAIERROR,
                            mode: 'sticky'
                        });
                        this.dispatchEvent(toastMessageErrorAI);
                        this.isSubmitSpinner = false;
                        this.disableButton = false;
                        this.aIButtonLabel = runAIButton;
                        if (this.isAutoAI || this.isClient) {
                            this.getAIMessage = false;
                            this.getQuotelineData();
                        }
                    }
                    else {
                        let qlRecJSONData = JSON.parse(result[0]);
                        this.recommendedPrice = qlRecJSONData.recommendedPrice;
                        this.priceInterval = qlRecJSONData.priceInterval;
                        this.pricingDiscount = qlRecJSONData.discount;
                        const saveFields = this.template.querySelectorAll('lightning-input-field');
                        if (saveFields) {
                            saveFields.forEach(field => {
                                if (field.fieldName === this.recommendedPriceAPIField) {
                                    field.value = Math.round(this.recommendedPrice);
                                }
                                if (field.fieldName === this.priceIntervalAPIField) {
                                    field.value = this.priceInterval;
                                }
                                if (field.fieldName === this.pricingDiscountAPIField) {
                                    field.value = this.pricingDiscount;
                                }
                            });
                        }
                        if (qlRecJSONData.warningMessage != '' && qlRecJSONData.warningMessage != undefined) {
                            const warningMsgAI = new ShowToastEvent({
                                title: 'Warning',
                                message: qlRecJSONData.warningMessage,
                                variant: 'warning',
                                mode: 'sticky'
                            });
                            this.dispatchEvent(warningMsgAI);
                        }
                        this.isSubmitSpinner = false;
                        this.disableButton = false;
                        this.aIButtonLabel = runAIButton;
                        if (this.isAutoAI || this.isClient) {
                            this.getQuotelineData();
                        }
                    }
                } else {
                    this.isSubmitSpinner = false;
                    this.disableButton = false;
                    this.aIButtonLabel = runAIButton;
                    if (this.isAutoAI || this.isClient) {
                        this.getQuotelineData();
                    }
                }
            })
            .catch(error => {
                this.error = error;
                const toastMessageExcepion = new ShowToastEvent({
                    title: TITLE_TEXTAIERROR,
                    message: 'Error processing response from Pricing AI. Please check the request and try again.',
                    variant: VAR_TEXTAIERROR,
                    mode: 'sticky'
                });
                this.dispatchEvent(toastMessageExcepion);
                this.saveLabel = saveButton;
                this.aIButtonLabel = runAIButton;
                this.isSubmitSpinner = false;
                this.disableButton = false;
                if (this.isAutoAI || this.isClient) {
                    this.getAIMessage = false;
                    this.getQuotelineData();
                }
            });
    }

}