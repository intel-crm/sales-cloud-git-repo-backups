import {
    LightningElement,
    track,
    api
}
from 'lwc';
import {
    NavigationMixin
}
from 'lightning/navigation';
import getObjectFields from '@salesforce/apex/Core_MDF_CampaignCreatePage.getObjectFields';
import getAccPropBasedValues from '@salesforce/apex/Core_MDF_CampaignCreatePage.getAccPropBasedValues';
import getAccSpecificBudgetTypes from '@salesforce/apex/Core_MDF_CampaignCreatePage.getAccSpecificBudgetTypes';
import saveCampaign from '@salesforce/apex/Core_MDF_CampaignCreatePage.saveCampaign';
import loadCampaignRecord from '@salesforce/apex/Core_MDF_CampaignCreatePage.loadRecord';
import getFieldEditibilityMapping from '@salesforce/apex/Core_MDF_CampaignCreatePage.getFieldEditibilityMapping';
import checkClaimsAssociatedToCampaign from '@salesforce/apex/Core_MDF_CampaignCreatePage.checkClaimsAssociatedToCampaign';
import Core_MDF_Save from "@salesforce/label/c.Core_MDF_Save";
import Core_MDF_Cancel from "@salesforce/label/c.Core_MDF_Cancel";
import Core_MDF_Country_Filter from "@salesforce/label/c.Core_MDF_Country_Filter";
import Core_MDF_PFR_None_Translation from "@salesforce/label/c.Core_MDF_PFR_None_Translation";
import Core_MDF_ApplicationErrorMessage from "@salesforce/label/c.Core_MDF_ApplicationErrorMessage";
import Core_MDF_IPA_Others_Message from "@salesforce/label/c.Core_MDF_IPA_Others_Message";
import Core_MDF_Chosen_Label from "@salesforce/label/c.Core_MDF_Chosen_Label";
import Core_MDF_Available_Label from "@salesforce/label/c.Core_MDF_Available_Label";
import Core_MDF_Edit from "@salesforce/label/c.Core_MDF_Edit";
import getBudgetsForCampaign from '@salesforce/apex/Core_MDF_CampaignCreatePage.getBudgetsForCampaign';
import Core_MDF_CCF_Budget_Warning_Message from "@salesforce/label/c.Core_MDF_CCF_Budget_Warning_Message";
import Core_MDF_DCF_Budget_Warning_Message from "@salesforce/label/c.Core_MDF_DCF_Budget_Warning_Message";
import Core_MDF_No_Available_Budgets_Warning from "@salesforce/label/c.Core_MDF_No_Available_Budgets_Warning";
import getCampaignBudgetsForCampaign from '@salesforce/apex/Core_MDF_CampaignCreatePage.getCampaignBudgetsForCampaign';
import Core_MDF_OPAL_BudgetTypes from "@salesforce/label/c.Core_MDF_OPAL_BudgetTypes";
import Core_MDF_ExternalVisibilityError from '@salesforce/label/c.Core_MDF_ExternalVisibilityError';
import Core_MDF_CCF_RecordTypeName from "@salesforce/label/c.Core_MDF_CCF_RecordTypeName";
import Core_MDF_DCF_RecordTypeName from "@salesforce/label/c.Core_MDF_DCF_RecordTypeName";
import budgetTypeChangeWrng from "@salesforce/label/c.Core_MDF_BudgetType_Change_Warning";
import Core_MDF_Campaign_Budgets_Error from "@salesforce/label/c.Core_MDF_Campaign_Budgets_Error";
import Core_MDF_Available_Budgets_Label from "@salesforce/label/c.Core_MDF_Available_Budgets_Label";
import Core_MDF_IPA_RecordType from '@salesforce/label/c.Core_MDF_IPA_RecordType';
import Core_MDF_budgetTypeRRValuesMap from '@salesforce/label/c.Core_MDF_budgetTypeRRValuesMap';
import Core_MDF_CampaignBudgets_ErrMsg from '@salesforce/label/c.Core_MDF_CampaignBudgets_ErrMsg';
import loadDynamicFields from '@salesforce/apex/Core_MDF_CampaignCreatePage.loadDynamicFields';
import Core_MDF_Multiple_Countries_Soft_Msg from '@salesforce/label/c.Core_MDF_Multiple_Countries_Soft_Msg';
import Core_MDF_Multi_Geo_Error from '@salesforce/label/c.Core_MDF_Country_Multiple_Geo_Error';
import Core_MDF_Activity_Type from '@salesforce/label/c.Core_MDF_Activity_Type';
import Core_MDF_Start_Date from "@salesforce/label/c.Core_MDF_Start_Date";
import Core_MDF_End_Date from "@salesforce/label/c.Core_MDF_End_Date";
import Core_MDF_StartEndDate_Soft_Msg from "@salesforce/label/c.Core_MDF_StartEndDate_Soft_Msg";
import Core_MDF_KpiSection_Label from "@salesforce/label/c.Core_MDF_KpiSection_Label";
import campaignDateRangeErr from "@salesforce/label/c.Core_MDF_Campaign_Date_Check_Error";
import Core_MDF_Activity_Note from "@salesforce/label/c.Core_MDF_Activity_Note";
import Core_MDF_Proposal_EndDate_ErrMsg from '@salesforce/label/c.Core_MDF_Proposal_EndDate_ErrMsg';
import Core_MDF_Activity_Creation_Page_Header from '@salesforce/label/c.Core_MDF_Activity_Creation_Page_Header';
import fetchPicklist from './core_MDF_Create_Campaign_Helper.js';
import Core_MDF_Complete_SPIF_Warning from '@salesforce/label/c.Core_MDF_Complete_SPIF_Warning';
import checkEditProposalAccess from '@salesforce/apex/Core_MDF_CampaignCreatePage.checkEditProposalAccess';
import getFieldSetName from '@salesforce/apex/Core_MDF_CampaignCreatePage.getFieldSetName';
import Core_MDF_IPA_NA_Message from "@salesforce/label/c.Core_MDF_IPA_NA_Message";

export default class Core_MDF_CampaignEditMode extends NavigationMixin(LightningElement) {
     @ api recordTypeId;
     @ api recordTypeName;
     @ api recordTypeDeveloperName;
     @ api recordId;
     @ api objectApiName;
     @ api fieldSetName;
     @ api mode;
     @ api status;
     @ api isCommunity;
     @ api pfrEditRecord;
     @ api proposalBasedIndicator;
     @ api claimAssociatedIndicator;
     @ track mandateComment = false;
     @ track isLoaded = false;
     @ track campaignFields;
     @ track campaignFieldVisibility = {};
     @ track campaignFieldDisabled = {};
     @ track campaignFieldLabel = {};
     @ track campaignFieldHelpText = {};
     @ track campaignFieldValue = {};
     @ track campaignRequiredFields = {};
     @ track campaignPicValues = {};
     @ track countryOption = {};
     @ track btnDisabled = {
        cancelBtn: false,
        saveAndNewBtn: true,
        saveBtn: true
    };
     @ track error;
     @ track picValuesByRecType;
     @ track countryPicklist;
     @ track othersHelpText = {};
     @ track countryValue = [];
     @ track geoValue = [];
     @ track tempCountrySelected = [];
     @ track tempGeoSelected = [];
     @ track showForm = false;
     @ track showAvailableBudgets = false;
     @ track showAvailableBudgetRequired = false;
     @ track showCampaignBudgets = false;
     @ track showLegacyFields = false;
     @ track activityFields;
     @ track activityRequiredFields = {};
     @ track budgetWarning = {};
     @ track availableBudgetWarning = {};
     @ track campaignBudgetsForSave = [];
     @ track finalDependentVal = [];
     @ track countryPicklist = [];
     @ track onBudgetTypeChange = false;
     @ track storeBudgetType;
     @ track noBudgetsWarning = false;
     @ track selectedAvailableBudgets = [];
     @ track selectedCmpBudgets = [];
     @ track arrayFromAvailableBudgets = [];
     @ track ConnectedCallbackGeoCountryValue = new Map();
     @ track budgetIdTypeMap = new Map();
     @ track isBudgetAmountDecreased = false;
     @ track multipleGeoSelected = false;
     @ api activityListClone = [];
     @ track mandatoryActFieldsError = false;
     @ track recPFRList = [];
     @ track expandDetail;
     @ track showSPIFRestrictError = false;
     @ track campaignDateRangeError = false;
     @ track savePFRClonecampaign = true;
     @ track viewActivityFieldList = [];
     @ track updatedActivityFieldsvalue;
     @ track pfrListCloneInsert = [];
     @ track checkIfClone = false;
     @ track campSection;
     @ track isEdit = true;
     @ track CountryDisplay = [];
     @ track allCountryDisplay = [];
     @ track initialRRValue;
     @ track customRRValues = [];
     @ track finalRRrate;
     @ track customRRate;
     @ track isClaimsAcssociated = false;
     @ track crrHelpText = false;
     @ track crrMessage = '';
     @ track isCustomRRValid = true;
     @ track hideGenericError = false;
     @ track proposalBasedIndicatorCamp = undefined;
     @ track accountBasedIndicatorCamp = undefined;
     @ track previousCampaignCountries = [];
     @ track isCountryChanged = false;
     @ track recActList;
     @ api budgetOptions;
     @ api startEndDateErr = false;
    isProposalCampaign;
    program;
    selectedActCatTypePicValues = '';
    pageHeaderTxt = '';
    startEndDateSoftWarning = Core_MDF_StartEndDate_Soft_Msg;
    sourceLabelStr = Core_MDF_Available_Label;
    selectedLabelStr = Core_MDF_Chosen_Label;
    countryFilterLabelTxt = Core_MDF_Country_Filter;
    saveBtnLabelTxt = Core_MDF_Save;
    cancelBtnLabelTxt = Core_MDF_Cancel;
    noneStr = Core_MDF_PFR_None_Translation;
    applicationErrorMsg = Core_MDF_ApplicationErrorMessage;
    accountQueryFilter = '';
    othersMessage = Core_MDF_IPA_Others_Message;
    editText = Core_MDF_Edit;
    ccfBudgetWarningMessage = Core_MDF_CCF_Budget_Warning_Message;
    dcfBudgetWarningMessage = Core_MDF_DCF_Budget_Warning_Message;
    availableBudgetWarningMessage = Core_MDF_No_Available_Budgets_Warning;
    campaignBudgetsError = Core_MDF_Campaign_Budgets_Error;
    availableBudgetsLabel = Core_MDF_Available_Budgets_Label;
    spifWarningError = Core_MDF_Complete_SPIF_Warning;
    multipleCountriesSoftMsg = Core_MDF_Multiple_Countries_Soft_Msg;
    multipleGeoError = Core_MDF_Multi_Geo_Error;
    datevalid = true;
    countryError = false;
    industryError = false;
    multiGeoError = false;
    activityType = Core_MDF_Activity_Type;
    startDate = Core_MDF_Start_Date;
    endDate = Core_MDF_End_Date;
    campActDateerror = campaignDateRangeErr;
    metrics = Core_MDF_KpiSection_Label;
    note = Core_MDF_Activity_Note;
    availableBudgetValues = [];
    budgetsOnActiveActivities = [];
    cloneHeader = Core_MDF_Activity_Creation_Page_Header;
    endDateExtensionErrorMsg = Core_MDF_Proposal_EndDate_ErrMsg;
    campaignBudgets = [];
    oldcampaignBudgets = [];
    allCampaignBudgets = [];
    allCmpBudgetsMap = new Map();
    selectedAvailableBudgetsMap = new Map();
     @ track selectPartnerBudgetTypeWarning = {};
    accountDisable = undefined;
    accountVisible = true;
     @ track naHelpText = {};
    naMessage = Core_MDF_IPA_NA_Message;
    selectPartnerBudgetTypeError = '';
    budgetTypeRrOptionMap = new Map();
    budgetTypeRrOptionsStr = Core_MDF_budgetTypeRRValuesMap;
    budgetAmountDecreasedErr = Core_MDF_CampaignBudgets_ErrMsg;
    memberVisibilityValid = false;
    memberVisibilityError = Core_MDF_ExternalVisibilityError;
    
    
    connectedCallback() {
        
        if (this.recordId != undefined && this.recordId != null && this.recordId != '' && (this.mode == 'edit')) {
            this.getBudgetsOnActiveActivities();
        }
        
        if ((this.recordTypeDeveloperName == Core_MDF_IPA_RecordType)
             && this.mode === 'edit' && (this.status === 'In Progress' || this.status == 'Planned')) {
            checkClaimsAssociatedToCampaign({
                campaignId: this.recordId
            })
            .then(result => {
                this.isClaimsAcssociated = result;
            })
            .catch(error => {});
        }
    }
    
    initialization() {
        if (this.recordId != undefined && this.recordId != null && this.recordId != '' && (this.mode == 'edit' || this.mode == 'clone')) {
            this.isLoaded = true;
            if (this.mode == 'edit') {
                checkEditProposalAccess({
                    campaignId: this.recordId,
                    recTypeDevloperName: this.recordTypeDeveloperName
                }).then(result => {
                    if (result.isEditProposalAccess == false) {
                        this.showErrorToast(result.returnValue);
                        this.navigateToRecordDetailPage(this.objectApiName, this.recordId);
                        setTimeout(function () {
                            window.location.reload();
                        }, 1000);
                    }
                    getFieldEditibilityMapping({
                        objectName: this.objectApiName,
                        recTypeDevloperName: this.recordTypeDeveloperName,
                        status: this.status,
                        campaignId: this.recordId,
                        proposalBasedIndicator: result.isProposalBased,
                        claimAssociatedIndicator: result.isClaimAssociated
                    })
                    .then(result => {
                        console.log('field edit: ' + JSON.stringify(result));
                        if (result) {
                            this.fieldEditibilityList = result;
                            if (this.fieldEditibilityList !== undefined && this.fieldEditibilityList !== null && this.fieldEditibilityList.length === 0) {
                                this.btnDisabled["saveBtn"] = true;
                            }
                        }
                    })
                    .catch(error => {})
                }).catch(error => {})
            }
            if (this.mode == 'edit' || this.mode == 'clone') {
                getCampaignBudgetsForCampaign({
                    campaignId: this.recordId
                })
                .then(result => {
                    if (result !== undefined && result !== null && result.length > 0) {
                        let selBudgetIds = [];
                        let campaignBudgetsArray = [];
                        for (let i = 0; i < result.length; i++) {
                            if (!selBudgetIds.includes(result[i].Core_MDF_Budget_Name_Id__c) && result[i].Core_MDF_Active_ind__c == true) {
                                selBudgetIds = [...selBudgetIds, result[i].Core_MDF_Budget_Name_Id__c];
                                this.selectedAvailableBudgetsMap.set(result[i].Core_MDF_Budget_Name_Id__c, result[i]);
                            }
                            let rrOptions;
                            if (this.budgetIdTypeMap.has(result[i].Core_MDF_Budget_Name_Id__c)) {
                                const budgetType = this.budgetIdTypeMap.get(result[i].Core_MDF_Budget_Name_Id__c);
                                if (this.budgetTypeRrOptionMap.has(budgetType)) {
                                    rrOptions = this.budgetTypeRrOptionMap.get(budgetType);
                                }
                            }
                            let budgetNameString = result[i].Core_MDF_Budget_Name_Id__r.Title + ' - ' + result[i].Core_MDF_Budget_Type_Nm__c + ' - ' + result[i].Core_MDF_Start_Date_Dt__c + ' - ' + result[i].Core_MDF_End_Date_Dt__c;
                            let obj;
                            if (this.mode === 'edit' && result[i].Core_MDF_Active_ind__c) {
                                if (this.budgetsOnActiveActivities.includes(result[i].Core_MDF_Budget_Name_Id__c)) {
                                    obj = {
                                        campaignBudgetId: result[i].Id,
                                        isActive: true,
                                        disable: true,
                                        budgetId: result[i].Core_MDF_Budget_Name_Id__c,
                                        budgetName: budgetNameString,
                                        budgetAmount: result[i].Core_MDF_Budget_Amt__c,
                                        budgetRR: result[i].Core_MDF_Reimbursement_Rate_Pct__c,
                                        budgetRAmount: result[i].Core_MDF_Reimbursement_Amt__c,
                                        options: rrOptions
                                    };
                                    campaignBudgetsArray = [...campaignBudgetsArray, obj];
                                } else {
                                    obj = {
                                        campaignBudgetId: result[i].Id,
                                        isActive: true,
                                        disable: false,
                                        budgetId: result[i].Core_MDF_Budget_Name_Id__c,
                                        budgetName: budgetNameString,
                                        budgetAmount: result[i].Core_MDF_Budget_Amt__c,
                                        budgetRR: result[i].Core_MDF_Reimbursement_Rate_Pct__c,
                                        budgetRAmount: result[i].Core_MDF_Reimbursement_Amt__c,
                                        options: rrOptions
                                    };
                                    campaignBudgetsArray = [...campaignBudgetsArray, obj];
                                }
                            } else if (this.mode === 'clone' && result[i].Core_MDF_Active_ind__c) {
                                obj = {
                                    budgetId: result[i].Core_MDF_Budget_Name_Id__c,
                                    isActive: true,
                                    budgetName: budgetNameString,
                                    budgetAmount: result[i].Core_MDF_Budget_Amt__c,
                                    budgetRR: result[i].Core_MDF_Reimbursement_Rate_Pct__c,
                                    budgetRAmount: result[i].Core_MDF_Reimbursement_Amt__c,
                                    options: rrOptions
                                };
                                campaignBudgetsArray = [...campaignBudgetsArray, obj];
                            }
                            this.allCmpBudgetsMap = this.allCmpBudgetsMap.set(result[i].Core_MDF_Budget_Name_Id__c, result[i]);
                        }
                        this.oldcampaignBudgets = campaignBudgetsArray;
                        this.campaignBudgetsForSave = campaignBudgetsArray;
                        this.selectedAvailableBudgets = selBudgetIds;
                        this.selectedCmpBudgets = selBudgetIds;
                    }
                })
                .catch(error => {})
            }
            loadCampaignRecord({
                recordId: this.recordId,
                objectName: this.objectApiName,
                fieldSetName: this.fieldSetName
            })
            .then(result => {
                if (result) {
                    this.campaignRecord = result;
                    this.selectedAccount = {
                        Id: result["Core_MDF_Account__r"].Id,
                        Name: result["Core_MDF_Account__r"].Name
                    };
                    this.selectedAccountId = result["Core_MDF_Account__r"].Id;
                    this.selectedBudType = result["Core_MDF_Opal_Budget_Type_Txt__c"];
                    this.isProposalCampaign = result["Core_MDF_Proposal_Based_Ind__c"];
                    this.program = result["Core_MDF_Program__c"];
                    if ((this.mode === 'edit' || this.mode === 'clone') && (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType)) {
                        if (this.campaignFieldValue["Core_MDF_Integrated_Campaign__c"] == 'Yes') {
                            this.campaignRequiredFields["Core_MDF_Integrated_Campaign_Details__c"] = true;
                        }
                        this.handleSelectedAccount(this.selectedAccountId);
                        this.getBudgetTypeValue(this.selectedBudType, this.program);
                    }
                    if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
                        getFieldSetName({
                            pickListObj: 'Core_MDF_Custom_Picklist__c',
                            budType: this.selectedBudType,
                            objectName: 'Campaign'
                        })
                        .then(result => {
                            this.fieldSetApiName = result[0].Core_MDF_FieldSet_API_Name__c;
                            const pr = new Promise((resolve, reject) => {
                                setTimeout(() => {
                                    resolve();
                                }, 1000);
                            });
                            Promise.all([getAccPropBasedValues, loadDynamicFields, fetchPicklist, pr]).then((val) => {
                                this.getCampaignFields();
                            })
                        }).catch(error => console.log(error));
                    } else {
                        this.getCampaignFields();
                    }
                }
            })
            .catch(error => {
                this.isLoaded = false;
            })
        }
    }
    getCampaignFields() {
        let editconnectedCallbackcusts = [];
        let objAPIName;
        let fldSetName = this.fieldSetApiName;
        if ((this.recordTypeDeveloperName == Core_MDF_IPA_RecordType) && (this.mode === 'edit' || this.mode === 'clone')) {
            objAPIName = 'Core_MDF_Custom_Picklist__c';
            fldSetName = this.fieldSetApiName;
        }
        getObjectFields({
            objectName: objAPIName,
            fieldSetName: fldSetName
        })
        .then(result => {
            this.campaignFields = result;
            if (this.campaignFields != undefined && this.campaignFields != null) {
                for (let i = 0; i < this.campaignFields.length; i++) {
                    if (this.recordId != undefined && this.recordId != null && this.recordId != '' && this.mode == 'edit') {
                        if (this.fieldEditibilityList != null && this.fieldEditibilityList.includes(this.campaignFields[i].fieldAPIName)) {
                            this.campaignFieldDisabled[this.campaignFields[i].fieldAPIName] = false;
                        } else {
                            this.campaignFieldDisabled[this.campaignFields[i].fieldAPIName] = true;
                        }
                        if (this.campaignFields[i].fieldAPIName == 'StartDate__c' || this.campaignFields[i].fieldAPIName == 'EndDate__c' || this.campaignFields[i].fieldAPIName == 'Name__c' || this.campaignFields[i].fieldAPIName == 'Description__c') {
                            this.campaignFields[i].fieldAPIName = this.campaignFields[i].fieldAPIName.replace('__c', '');
                        }
                        if (this.campaignRecord[this.campaignFields[i].fieldAPIName] != null && this.campaignRecord[this.campaignFields[i].fieldAPIName] != undefined) {
                            this.campaignFieldValue[this.campaignFields[i].fieldAPIName] = this.campaignRecord[this.campaignFields[i].fieldAPIName];
                        } else {
                            this.campaignFieldValue[this.campaignFields[i].fieldAPIName] = '';
                        }
                    }
                    if (this.recordId != undefined && this.recordId != null && this.recordId != '' && (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) && (this.mode == 'edit' || this.mode == 'clone')) {
                        if (this.campaignFields[i].fieldAPIName == 'Core_MDF_ReimbursementRate_pct__c') {
                            this.finalRRrate = this.campaignFieldValue[this.campaignFields[i].fieldAPIName];
                            this.initialRRValue = this.campaignFieldValue["Core_MDF_Reimbursement_Rate__c"];
                        }
                        if (this.campaignFieldValue["Core_MDF_Custom_Reimbursement_Rate_pct__c"] != null && this.campaignFieldValue["Core_MDF_Custom_Reimbursement_Rate_pct__c"] != ""
                             && this.campaignFieldValue["Core_MDF_Custom_Reimbursement_Rate_pct__c"] != undefined) {
                            this.campaignFieldDisabled["Core_MDF_Reimbursement_Rate__c"] = true;
                        }
                        this.initialRRValue = '50%';
                    }
                    if (this.mode == 'edit' && (this.status == 'In Progress' || this.status == 'Planned') && ((this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) && this.isProposalCampaign)) {
                        this.campaignFieldDisabled["Core_MDF_Custom_Reimbursement_Rate_pct__c"] = true;
                    }
                    if (this.campaignFields[i].fieldType == 'PICKLIST' || this.campaignFields[i].fieldType == 'MULTIPICKLIST') {
                        if (this.picValuesByRecType !== undefined && this.picValuesByRecType !== null) {
                            if (this.recordId != undefined && this.recordId != null && this.recordId != '' && (this.mode == 'edit' || this.mode == 'clone')) {
                                let selectedPicValues = this.campaignRecord[this.campaignFields[i].fieldAPIName];
                                if (selectedPicValues != undefined && selectedPicValues != null && selectedPicValues != '') {
                                    selectedPicValues = selectedPicValues.split(';');
                                    let allValues = this.campaignPicValues[this.campaignFields[i].fieldAPIName];
                                    if (allValues != null && allValues != undefined) {
                                        let index = 0;
                                        let arrLength = allValues.length;
                                        let missingValues = [];
                                        var allValueArray = [];
                                        for (index = 0; index < arrLength; index++) {
                                            allValueArray = [...allValueArray, allValues[index].value];
                                        }
                                        for (let index2 = 0; index2 < selectedPicValues.length; index2++) {
                                            if (!allValueArray.includes(selectedPicValues[index2])) {
                                                let obj = {
                                                    label: selectedPicValues[index2],
                                                    value: selectedPicValues[index2]
                                                };
                                                missingValues = [...missingValues, obj];
                                            }
                                        }
                                        if (this.mode == 'edit' && this.recordTypeDeveloperName != Core_MDF_IPA_RecordType) {
                                            var missingValuesArr = [];
                                            for (index = 0; index < missingValues.length; index++) {
                                                if (!missingValuesArr.includes(missingValues[index].value)) {
                                                    allValues = [...allValues, missingValues[index]];
                                                    missingValuesArr = [...missingValuesArr, missingValues[index].value];
                                                }
                                            }
                                            this.campaignPicValues[this.campaignFields[i].fieldAPIName] = allValues;
                                        }
                                        
                                        if ((this.mode == 'edit' || this.mode == 'clone') && this.campaignFields[i].fieldAPIName == 'Core_MDF_Reimbursement_Rate__c'
                                             && this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
                                            if (!this.customRRValues.includes(this.finalRRrate) && this.campaignFieldValue["Core_MDF_Custom_Reimbursement_Rate_pct__c"] != null && this.campaignFieldValue["Core_MDF_Custom_Reimbursement_Rate_pct__c"] != ""
                                                 && this.campaignFieldValue["Core_MDF_Custom_Reimbursement_Rate_pct__c"] != undefined) {
                                                this.customRRValues.push({
                                                    label: this.finalRRrate,
                                                    value: this.finalRRrate
                                                });
                                            } 
                                        }
                                    }
                                }
                               
                            }
                        }
                    }
                    
                    if (this.recordId != undefined && this.recordId != null && this.recordId != '' && this.mode == 'edit') {
                        this.campaignFieldValue["Id"] = this.recordId;
                        this.pageHeaderTxt = this.editText + ' ' + this.campaignFieldValue["Name"];
                    }
                }
                if (this.recordId != undefined && this.recordId != null && this.recordId != '' && (this.mode == 'edit' || this.mode == 'clone')) {
                    if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
                        this.setCCFDCFFields(this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c']);
                    } else {
                        this.setCCFDCFFields(this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c']);
                    }
                }
                
                if (this.recordId != undefined && this.recordId != null && this.recordId != '' && (this.mode == 'edit' || this.mode == 'clone')) {
                    this.calReimbursementAmt();
                }
                
                if (this.recordId != undefined && this.recordId != null && this.recordId != '' && (this.mode == 'edit' || this.mode == 'clone')) {
                    this.setCCFDCFFields(this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c']);
                }
                if (this.mode == 'edit') {
                    if (this.recordTypeDeveloperName === Core_MDF_DCF_RecordTypeName || this.recordTypeDeveloperName === Core_MDF_CCF_RecordTypeName) {
                        if (this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] != undefined && this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] != null && this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] != '') {
                            var opalList = Core_MDF_OPAL_BudgetTypes.split(';');
                            if (opalList != undefined && opalList != null && opalList != '') {
                                for (let index = 0; index < opalList.length; index++) {
                                    if (this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"].includes(opalList[index])) {
                                        this.campaignFieldDisabled["Core_MDF_Account__c"] = true;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
                        this.accountDisable = true;
                        this.accountVisible = false;
                    }
                }
            }
            
        })
        .catch(e => {
            this.isLoaded = false;
            this.btnDisabled["saveBtn"] = false;
            this.scrollUp();
        });
    }
    
    setCCFDCFFields(budgetType) {
        try {
            if (budgetType == 'CCF 1.0' || budgetType == 'DCF 1.0') {
                if (this.mode != 'edit' && this.mode != 'clone') {
                    this.campaignFieldValue["Core_MDF_Reimbursement_Rate__c"] = '50%';
                }
            }
            if ((this.campaignFieldValue["Core_MDF_Program__c"] == 'Intel Partner Alliance') && this.mode != 'edit' && this.mode != 'clone') {
                this.clearValuesIfProposalCamp();
            }
        } catch (e) {}
    }
    
    checkSelPicVal() {
        this.selectedActCatTypePicValues = this.campaignFieldValue?.['Core_MDF_Activity_Category_Type__c'];
        if (this.selectedActCatTypePicValues != undefined && this.selectedActCatTypePicValues != null && this.selectedActCatTypePicValues != '') {
            let allValues = this.finalDependentVal;
            if (allValues != null && allValues != undefined) {
                let index = 0;
                let arrLength = allValues.length;
                let missingValues = [];
                var allValueArray = [];
                for (index = 0; index < arrLength; index++) {
                    allValueArray = [...allValueArray, allValues[index].value];
                }
                for (let index2 = 0; index2 < this.selectedActCatTypePicValues.length; index2++) {
                    if (!allValueArray.includes(this.selectedActCatTypePicValues[index2])) {
                        let obj = {
                            label: this.selectedActCatTypePicValues[index2],
                            value: this.selectedActCatTypePicValues[index2]
                        };
                        missingValues = [...missingValues, obj];
                    }
                }
                if (this.mode == 'clone' || this.mode == 'edit') {
                    let newValues = [];
                    var missingValuesArr = [];
                    for (let index2 = 0; index2 < missingValues.length; index2++) {
                        if (!missingValuesArr.includes(missingValues[index2].value)) {
                            missingValuesArr = [...missingValuesArr, missingValues[index2].value];
                        }
                    }
                    if (missingValuesArr != null && missingValuesArr != undefined && missingValuesArr != '' && this.selectedActCatTypePicValues != undefined && this.selectedActCatTypePicValues != null && this.selectedActCatTypePicValues != '') {
                        for (let index = 0; index < this.selectedActCatTypePicValues.length; index++) {
                            if (!missingValuesArr.includes(this.selectedActCatTypePicValues[index])) {
                                if (!newValues.includes(this.selectedActCatTypePicValues[index])) {
                                    newValues = [...newValues, this.selectedActCatTypePicValues[index]];
                                }
                            }
                        }
                        if (newValues != undefined && newValues != null && newValues.length > 0) {
                            this.selectedActCatTypePicValues = newValues;
                        }
                    }
                }
            }
        }
    }
   
    async getBudgetTypeValue(budgettype, campProg) {
        var campRecordTypeName;
        if (budgettype !== undefined && budgettype !== null && budgettype !== '') {
            await getAccPropBasedValues({
                campBudgetType: budgettype,
                program: campProg
            })
            .then((result) => {
                for (const key in result) {
                    if (key == "Proposal Based") {
                        if (this.mode == 'edit' && !this.proposalBasedIndicatorCamp) {
                            this.clearValuesIfProposalCamp();
                        }
                    }
                }
            })
            .catch(e => {});
        }
    }
    async getDynamicFields(CustomPicklistObject, budgettype, currentObjAPIName) {
        await loadDynamicFields({
            pickListObj: CustomPicklistObject,
            budType: budgettype,
            objectName: currentObjAPIName
        })
        .then((result) => {
            if ((this.campaignFieldVisibility.StartDate__c && this.campaignFieldVisibility.EndDate__c && this.campaignFieldVisibility.Name__c) && (this.mode == 'clone' || this.mode == 'edit')) {
                this.showFields = true;
            }
        })
    }
    
    onBudgetSelection(event) {
        
        if (this.mode === 'edit' && this.allCmpBudgetsMap !== null) {
            let selectedBudgets = [];
            this.selectedCmpBudgets = [];
            let rrOptions;
            for (var i in arrayFromChild) {
                if (!selectedBudgets.includes(arrayFromChild[i].value)) {
                    selectedBudgets = [selectedBudgets, arrayFromChild[i].value];
                    this.selectedCmpBudgets = [...this.selectedCmpBudgets, arrayFromChild[i].value];
                }
                if (this.budgetIdTypeMap.has(arrayFromChild[i].value)) {
                    const budgetType = this.budgetIdTypeMap.get(arrayFromChild[i].value);
                    if (this.budgetTypeRrOptionMap.has(budgetType)) {
                        rrOptions = this.budgetTypeRrOptionMap.get(budgetType);
                    }
                }
                if (this.allCmpBudgetsMap.has(arrayFromChild[i].value)) {
                    let res = this.allCmpBudgetsMap.get(arrayFromChild[i].value);
                    let budgetNameString = res.Core_MDF_Budget_Name_Id__r.Title + ' - ' + res.Core_MDF_Budget_Type_Nm__c + ' - ' + res.Core_MDF_Start_Date_Dt__c + ' - ' + res.Core_MDF_End_Date_Dt__c;
                    let obj;
                    if (res.Core_MDF_Active_ind__c) {
                        if (this.budgetsOnActiveActivities.includes(res.Core_MDF_Budget_Name_Id__c)) {
                            obj = {
                                campaignBudgetId: res.Id,
                                budgetId: res.Core_MDF_Budget_Name_Id__c,
                                isActive: true,
                                disable: true,
                                budgetName: budgetNameString,
                                budgetAmount: res.Core_MDF_Budget_Amt__c,
                                budgetRR: res.Core_MDF_Reimbursement_Rate_Pct__c,
                                budgetRAmount: res.Core_MDF_Reimbursement_Amt__c,
                                options: rrOptions
                            };
                            campaignBudgetsArray = [...campaignBudgetsArray, obj];
                        } else {
                            obj = {
                                campaignBudgetId: res.Id,
                                budgetId: res.Core_MDF_Budget_Name_Id__c,
                                isActive: true,
                                disable: false,
                                budgetName: budgetNameString,
                                budgetAmount: res.Core_MDF_Budget_Amt__c,
                                budgetRR: res.Core_MDF_Reimbursement_Rate_Pct__c,
                                budgetRAmount: res.Core_MDF_Reimbursement_Amt__c,
                                options: rrOptions
                            };
                            campaignBudgetsArray = [...campaignBudgetsArray, obj];
                        }
                    } else {
                        obj = {
                            campaignBudgetId: res.Id,
                            isActive: true,
                            budgetId: arrayFromChild[i].value,
                            budgetName: arrayFromChild[i].label,
                            budgetAmount: '',
                            budgetRR: '50%',
                            budgetRAmount: '',
                            options: rrOptions
                        };
                        campaignBudgetsArray = [...campaignBudgetsArray, obj];
                    }
                } else {
                    if (cmpBudgetsTempMap !== undefined && cmpBudgetsTempMap !== null && cmpBudgetsTempMap.has(arrayFromChild[i].value)) {
                        let res = cmpBudgetsTempMap.get(arrayFromChild[i].value);
                        let obj = {
                            budgetId: res.budgetId,
                            budgetName: res.budgetName,
                            budgetAmount: res.budgetAmount,
                            budgetRR: res.budgetRR,
                            budgetRAmount: res.budgetRAmount,
                            options: rrOptions
                        };
                        campaignBudgetsArray = [...campaignBudgetsArray, obj];
                    } else {
                        let obj = {
                            budgetId: arrayFromChild[i].value,
                            budgetName: arrayFromChild[i].label,
                            budgetAmount: '',
                            budgetRR: '50%',
                            budgetRAmount: '',
                            options: rrOptions
                        };
                        campaignBudgetsArray = [...campaignBudgetsArray, obj];
                    }
                }
            }
        }
        
    }
    
    getBudgetsForCampaign(accountid, startdate, enddate, budgettype) {
        this.showAvailableBudgets = false;
        if (accountid !== undefined && accountid !== null && accountid !== '' && startdate !== undefined && startdate !== null && startdate !== ''
             && enddate !== undefined && enddate !== null && enddate !== '' && budgettype !== undefined && budgettype !== null && budgettype !== '') {
            getBudgetsForCampaign({
                campAccountId: accountid,
                campStartDate: startdate,
                campEndDate: enddate,
                campBudgetType: budgettype
            })
            .then((result) => {
                if (result) {
                    this.isLoaded = true;
                    let budgetTypePicValues = [];
                    var budgetType = result;
                    this.budgetIdTypeMap.clear();
                    let cmpBudgetsTempMap = new Map();
                    let budgetIdTypeMapTemp = new Map();
                    let selectedBudgetIds = [];
                    this.selectedCmpBudgets = [];
                    let campaignBudgetsArray = [];
                    if (this.campaignBudgetsForSave !== undefined && this.campaignBudgetsForSave !== null && this.campaignBudgetsForSave !== '') {
                        for (let i = 0; i < this.campaignBudgetsForSave.length; i++) {
                            if (this.mode === 'edit') {
                                cmpBudgetsTempMap[this.campaignBudgetsForSave[i].budgetId] = this.campaignBudgetsForSave[i];
                            } else {
                                cmpBudgetsTempMap.set(this.campaignBudgetsForSave[i].budgetId, this.campaignBudgetsForSave[i]);
                            }
                            selectedBudgetIds = [...selectedBudgetIds, this.campaignBudgetsForSave[i].budgetId];
                        }
                    }
                    if (this.mode === 'edit') {
                        if (this.budgetsOnActiveActivities !== undefined && this.budgetsOnActiveActivities !== null
                             && this.budgetsOnActiveActivities !== '') {
                            for (let i = 0; i < this.budgetsOnActiveActivities.length; i++) {
                                if (!selectedBudgetIds.includes(this.budgetsOnActiveActivities[i])) {
                                    selectedBudgetIds = [...selectedBudgetIds, this.budgetsOnActiveActivities[i]];
                                }
                            }
                        }
                    }
                    this.selectedAvailableBudgets = selectedBudgetIds;
                    for (const key in budgetType) {
                        budgetIdTypeMapTemp.set(key, result[key].Core_MDF_Budget_Type_Txt__c);
                        let obj;
                        if (this.selectedAvailableBudgets.includes(key)) {
                            if (this.budgetsOnActiveActivities.includes(key)) {
                                obj = {
                                    label: this.getBudgetNameString(result[key].Title, result[key].Core_MDF_Budget_Type_Txt__c, result[key].StartDate, result[key].EndDate),
                                    value: key,
                                    selected: true,
                                    disable: true,
                                };
                            } else {
                                obj = {
                                    label: this.getBudgetNameString(result[key].Title, result[key].Core_MDF_Budget_Type_Txt__c, result[key].StartDate, result[key].EndDate),
                                    value: key,
                                    selected: true,
                                    disable: false,
                                };
                            }
                            this.selectedCmpBudgets = [...this.selectedCmpBudgets, key];
                        } else {
                            obj = {
                                label: this.getBudgetNameString(result[key].Title, result[key].Core_MDF_Budget_Type_Txt__c, result[key].StartDate, result[key].EndDate),
                                value: key,
                            };
                        }
                        budgetTypePicValues = [...budgetTypePicValues, obj];
                        let rrOptions;
                        if (this.budgetTypeRrOptionMap.has(result[key].Core_MDF_Budget_Type_Txt__c)) {
                            rrOptions = this.budgetTypeRrOptionMap.get(result[key].Core_MDF_Budget_Type_Txt__c);
                        }
                        if (this.mode === 'edit' && this.allCmpBudgetsMap !== null) {
                            if (this.selectedAvailableBudgets.includes(key) && this.allCmpBudgetsMap.has(key)) {
                                let res = this.allCmpBudgetsMap.get(key);
                                let budgetNameString = res.Core_MDF_Budget_Name_Id__r.Title + ' - ' + res.Core_MDF_Budget_Type_Nm__c + ' - ' + res.Core_MDF_Start_Date_Dt__c + ' - ' + res.Core_MDF_End_Date_Dt__c;
                                let obj;
                                if (res.Core_MDF_Active_ind__c) {
                                    if (this.budgetsOnActiveActivities.includes(res.Core_MDF_Budget_Name_Id__c)) {
                                        obj = {
                                            campaignBudgetId: res.Id,
                                            budgetId: res.Core_MDF_Budget_Name_Id__c,
                                            isActive: true,
                                            disable: true,
                                            budgetName: budgetNameString,
                                            budgetAmount: res.Core_MDF_Budget_Amt__c,
                                            budgetRR: res.Core_MDF_Reimbursement_Rate_Pct__c,
                                            budgetRAmount: res.Core_MDF_Reimbursement_Amt__c,
                                            options: rrOptions
                                        };
                                        campaignBudgetsArray = [...campaignBudgetsArray, obj];
                                    } else {
                                        obj = {
                                            campaignBudgetId: res.Id,
                                            budgetId: res.Core_MDF_Budget_Name_Id__c,
                                            isActive: true,
                                            disable: false,
                                            budgetName: budgetNameString,
                                            budgetAmount: res.Core_MDF_Budget_Amt__c,
                                            budgetRR: res.Core_MDF_Reimbursement_Rate_Pct__c,
                                            budgetRAmount: res.Core_MDF_Reimbursement_Amt__c,
                                            options: rrOptions
                                        };
                                        campaignBudgetsArray = [...campaignBudgetsArray, obj];
                                    }
                                }
                            } else {
                                if (this.selectedAvailableBudgets.includes(key)) {
                                    let res = cmpBudgetsTempMap[key];
                                    if (res !== undefined && res !== null) {
                                        let obj = {
                                            budgetId: res.budgetId,
                                            budgetName: res.budgetName,
                                            budgetAmount: res.budgetAmount,
                                            budgetRR: res.budgetRR,
                                            budgetRAmount: res.budgetRAmount,
                                            options: rrOptions
                                        };
                                        campaignBudgetsArray = [...campaignBudgetsArray, obj];
                                    }
                                }
                            }
                        } else if (this.mode == 'clone') {
                            if (this.selectedCmpBudgets.includes(key)) {
                                let res = cmpBudgetsTempMap.get(key);
                                if (res !== undefined && res !== null) {
                                    let obj = {
                                        budgetId: res.budgetId,
                                        budgetName: res.budgetName,
                                        budgetAmount: res.budgetAmount,
                                        budgetRR: res.budgetRR,
                                        budgetRAmount: res.budgetRAmount,
                                        options: rrOptions
                                    };
                                    campaignBudgetsArray = [...campaignBudgetsArray, obj];
                                }
                            }
                        } else {
                            let res = cmpBudgetsTempMap.get(key);
                            if (res !== undefined && res !== null) {
                                let obj = {
                                    budgetId: res.budgetId,
                                    budgetName: res.budgetName,
                                    budgetAmount: res.budgetAmount,
                                    budgetRR: res.budgetRR,
                                    budgetRAmount: res.budgetRAmount,
                                    options: rrOptions
                                };
                                campaignBudgetsArray = [...campaignBudgetsArray, obj];
                            }
                        }
                    }
                    this.budgetIdTypeMap = budgetIdTypeMapTemp;
                    this.availableBudgetValues = budgetTypePicValues;
                    if (this.availableBudgetValues.length > 0) {
                        console.log('ENter at 889' + campaignBudgetsArray.stringify());
                        this.showAvailableBudgets = true;
                        this.showAvailableBudgetRequired = true;
                        this.availableBudgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
                        this.campaignBudgets = campaignBudgetsArray;
                        if (this.campaignBudgets !== undefined && this.campaignBudgets !== null && this.campaignBudgets.length > 0) {
                            this.showCampaignBudgets = true;
                            this.campaignBudgetsForSave = this.campaignBudgets;
                        }
                    } else {
                        this.availableBudgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = true;
                        this.showAvailableBudgets = false;
                        this.showAvailableBudgetRequired = false;
                        this.showCampaignBudgets = false;
                    }
                }
                this.isLoaded = false;
            })
            .catch(e => {
                this.isLoaded = false;
                this.campaignPicValues["Core_MDF_Opal_Budget_Type_Txt__c"] = '';
                this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
                this.scrollUp();
            });
        }
    }
     @ api isFormValid() {
        
        if (this.mode === 'edit' && (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType || (this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true))) {
            let oldEndDate = this.campaignRecord['EndDate'];
            let selectedEndDate;
            let inputElements = this.template.querySelectorAll("lightning-input");
            inputElements.forEach((element) => {
                if (element !== null && element.name === 'EndDate') {
                    selectedEndDate = element.value;
                }
            });
            if (oldEndDate !== selectedEndDate && (this.status === 'In Progress' || this.status === 'Planned') && this.isClaimsAcssociated && oldEndDate > selectedEndDate) {
                this.error = this.endDateExtensionErrorMsg;
                isEndDateNotChanged = false;
                this.hideGenericError = true;
            } else {
                this.error = null;
                isEndDateNotChanged = true;
            }
        }
        return isValid;
    }
    
    getCampaignFieldsValues() {
        try {
            
            if (this.mode != undefined && this.mode != null && this.mode != '' && this.mode == 'edit' && this.selectedAccount != undefined && this.selectedAccount != null && this.selectedAccount.Id != null) {
                this.campaignFieldValue["Core_MDF_Account__c"] = this.selectedAccount.Id;
            }
            if (this.mode != undefined && this.mode != null && this.mode != '' && (this.mode == 'edit' || this.mode == 'clone') && this.selectedActCatTypePicValues != undefined && this.selectedActCatTypePicValues != null && this.selectedActCatTypePicValues != null) {
                this.campaignFieldValue["Core_MDF_Activity_Category_Type__c"] = this.selectedActCatTypePicValues;
            }
        } catch (error) {
            this.error = true;
        }
        return this.campaignFieldValue;
    }
    customSave() {
        
        if (this.isFormValid() && this.savePFRClonecampaign && !this.mandatoryActFieldsError) {
            if (this.onBudgetTypeChange == true && this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] !== this.storeBudgetType && this.mode === 'edit') {
                this.showBudgetErrorToast(budgetTypeChangeWrng);
            }
            if (this.mode !== undefined && this.mode !== null && this.mode !== '' && this.mode === 'edit' && this.selectedAvailableBudgetsMap !== undefined && this.selectedAvailableBudgetsMap !== null && this.selectedAvailableBudgetsMap !== '') {
                if (this.campaignFieldValue["Core_MDF_Supports_legacy_program__c"] == 'Yes') {
                    this.selectedCmpBudgets = [];
                }
                for (let budgetId of this.selectedAvailableBudgetsMap.keys()) {
                    let selectedCmpBudgetsStr = this.selectedCmpBudgets.toString();
                    if (!selectedCmpBudgetsStr.includes(budgetId)) {
                        let res = this.allCmpBudgetsMap.get(budgetId);
                        var isDuplicate = false;
                        let budgetNameString = res.Core_MDF_Budget_Name_Id__r.Title + ' - ' + res.Core_MDF_Budget_Type_Nm__c + ' - ' + res.Core_MDF_Start_Date_Dt__c + ' - ' + res.Core_MDF_End_Date_Dt__c;
                        let obj = {
                            campaignBudgetId: res.Id,
                            budgetId: res.Core_MDF_Budget_Name_Id__c,
                            isActive: false,
                            budgetName: budgetNameString,
                            budgetAmount: res.Core_MDF_Budget_Amt__c,
                            budgetRR: res.Core_MDF_Reimbursement_Rate_Pct__c,
                            budgetRAmount: res.Core_MDF_Reimbursement_Amt__c
                        };
                        this.campaignBudgetsForSave.forEach(element => {
                            if (element.campaignBudgetId == obj.campaignBudgetId) {
                                element.isActive = obj.isActive;
                                isDuplicate = true;
                            }
                        });
                        if (!isDuplicate) {
                            this.campaignBudgetsForSave.push(obj);
                        }
                    }
                }
            }
            saveCampaign({
                campaignObj: this.getCampaignFieldsValues(),
                campaignBudgets: this.campaignBudgetsForSave,
                pfrList: this.pfrListCloneInsert
            })
            .then(result => {
                this.isLoaded = false;
                if (result != null && !result.startsWith('Exception')) {
                    this.navigateToRecordDetailPage(this.objectApiName, result);
                    this.error = undefined;
                    this.isLoaded = false;
                    if (this.mode == 'edit') {
                        setTimeout(function () {
                            window.location.reload();
                        }, 500);
                    }
                } else if (result != null && result.startsWith('Exception')) {
                    this.handleServerExceptions(result);
                    this.isLoaded = false;
                    this.btnDisabled["saveBtn"] = false;
                    this.btnDisabled["cancelBtn"] = false;
                    this.scrollUp();
                }
            }).catch(e => {
                if (e) {
                    this.handleServerExceptions(e.body.message);
                    this.isLoaded = false;
                    this.btnDisabled["saveBtn"] = false;
                    this.btnDisabled["cancelBtn"] = false;
                    this.scrollUp();
                }
            })
        }
    }
    
    async handleSelectedAccount(event) {
        this.selectPartnerBudgetTypeWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
        var selectedAccount = event.detail;
        this.program = this.program == undefined ? this.campaignFieldValue["Core_MDF_Program__c"] : this.program;
        if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
            if ((this.mode == 'edit' || this.mode == 'clone') && event.detail == undefined) {
                selectedAccount = event;
            }        
    }
}
    
    getAccountSpecificBudgetTypes(selectedAccount) {
        getAccSpecificBudgetTypes({
            accountId: String(selectedAccount),
            program: this.campaignFieldValue["Core_MDF_Program__c"]
        })
        .then(result => {
            if (result) {
                var budgetTypes = [];
                budgetTypes = result['accIdBudgetTypeMap'][selectedAccount];
                var budgetTypePicValues = [];
                if (budgetTypes != undefined && budgetTypes != null) {
                    for (const key in budgetTypes) {
                        const obj = {
                            label: budgetTypes[key],
                            value: key,
                        };
                        budgetTypePicValues = [...budgetTypePicValues, obj];
                    }
                }
                this.campaignPicValues["Core_MDF_Opal_Budget_Type_Txt__c"] = budgetTypePicValues;
                this.budgetOptions = budgetTypePicValues;
                if (this.recordId != undefined && this.recordId != null && this.recordId != '' && this.mode == 'edit') {
                    if (this.fieldEditibilityList != null && this.fieldEditibilityList.includes("Core_MDF_Opal_Budget_Type_Txt__c")) {
                        this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
                    } else {
                        this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = true;
                    }
                } else {
                    this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
                }
                if (this.isCommunity == true && this.recordId != undefined && this.recordId != null && this.recordId != '' && this.mode == 'edit') {

                    if (this.fieldEditibilityList != null && this.fieldEditibilityList.includes("Core_MDF_Opal_Budget_Type_Txt__c")) {

                        this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
                    } else {
                        this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = true;
                    }
                }
            }
            this.isLoaded = false;
        })
        .catch(e => {
            this.isLoaded = false;
            this.campaignPicValues["Core_MDF_Opal_Budget_Type_Txt__c"] = '';
            this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = true;
            this.scrollUp();
        })
    }
    
    searchCountry(event) {
        var countrySearch = event.target.value;
        countrySearch = countrySearch.toUpperCase();
        var countryName = this.countryPicklist;
        var filterCountrySearch = [];
        var filterCountryNonSearch = [];
        for (var index = 0; index < countryName.length; index++) {
            if (countryName[index].value.toUpperCase().includes(countrySearch)) {
                let obj = {
                    label: countryName[index].label,
                    value: countryName[index].value
                };
                filterCountrySearch = [...filterCountrySearch, obj];
            } else {
                let obj = {
                    label: countryName[index].label,
                    value: countryName[index].value
                };
                filterCountryNonSearch = [...filterCountryNonSearch, obj];
            }
        }
        for (let j = 0; j < filterCountryNonSearch.length; j++) {
            filterCountrySearch = [...filterCountrySearch, filterCountryNonSearch[j]];
        }
        this.campaignPicValues.Core_MDF_Market__c = filterCountrySearch;
        this.countryValue = this.tempCountrySelected;
    }
    
    handleCancel() {
        if (this.mode == 'edit' || this.mode == 'clone') {
            this.navigateToRecordDetailPage(this.objectApiName, this.recordId);
            if (this.mode == 'edit') {
                setTimeout(function () {
                    window.location.reload();
                }, 500);
            }
        }
    }
    
}