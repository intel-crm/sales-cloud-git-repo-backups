import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchRecords from '@salesforce/apex/Core_MDF_TargetSettingController.getLineItemRecords';
import fetchRecordTypeNames from '@salesforce/apex/Core_MDF_GenericMetadata.getObjectRecords';
import fetchRecordTypeId from '@salesforce/apex/Core_MDF_GenericMetadata.getRecordTypeId';
import getCountryGeoMap from '@salesforce/apex/Core_MDF_CCP_GenericUtility.getCountryGeoMap';
import updateCmpIdToSTLI from '@salesforce/apex/Core_MDF_TargetSettingController.updateCampaignIdtoSTLI';
import validateUserRegion from '@salesforce/apex/Core_MDF_TargetSettingController.validateUserRegion';
import checkUserAccess from '@salesforce/apex/Core_MDF_TargetSettingController.checkLoggedInUserhasAccess';
import TARGET_SETTING_LINE_ITEM_OBJECT from '@salesforce/schema/Core_MDF_Target_Setting_Line_Item__c';
import PRIORITY_FIELD from '@salesforce/schema/Core_MDF_Target_Setting_Line_Item__c.Core_MDF_Priority_nm__c';
import BUCKET_FIELD from '@salesforce/schema/Core_MDF_Target_Setting_Line_Item__c.Core_MDF_Bucket_nm__c';
import COUNTRY_FIELD from '@salesforce/schema/Core_MDF_Target_Setting_Line_Item__c.Core_MDF_Country_Name_nm__c';
import ACTIVE_VERSION from '@salesforce/schema/Core_MDF_Spending_Targets_Version__c.Core_MDF_Is_Active_Ind__c';
import CAMP_PRIORITY_FIELD from '@salesforce/schema/Core_MDF_Custom_Picklist__c.Core_MDF_Priority__c';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import RECORDTYPEID from '@salesforce/schema/Core_MDF_Spending_Targets_Version__c.Core_MDF_Spending_Targets__r.RecordType.DeveloperName';
import getConstants from '@salesforce/apex/Core_MDF_CCP_ConstantClass.getAllConstants';
import getRTFieldSet from '@salesforce/apex/Core_MDF_Campaign_QuickActionController.getRtFieldSetMappings';
import saveCampaign from '@salesforce/apex/Core_MDF_CampaignCreatePage.saveCampaign';
import ST_START_DATE from '@salesforce/schema/Core_MDF_Spending_Targets_Version__c.Core_MDF_Spending_Targets__r.Core_MDF_Start_Date__c';
import ST_END_DATE from '@salesforce/schema/Core_MDF_Spending_Targets_Version__c.Core_MDF_Spending_Targets__r.Core_MDF_End_Date__c';
import applicationError from '@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsg';
import selectOneAccLabel from '@salesforce/label/c.Core_MDF_SelectOneAccount';
import noSpendingItmAvaiable from '@salesforce/label/c.Core_MDF_NoSpendingItemAvailable';
import selectOneTargetItem from '@salesforce/label/c.Core_MDF_AtleastOneTargetItem';
import campaignDateBeyond2year from '@salesforce/label/c.Core_MDF_TargetSettingCampaignDateBeyond2Year';
import campaignDateInPast from '@salesforce/label/c.Core_MDF_TargetSettingCampaignInPast';
import CUSTOM_PICKLIST_OBJECT from '@salesforce/schema/Core_MDF_Custom_Picklist__c';
import CP_OBJ_COUNTRY_FIELD from '@salesforce/schema/Core_MDF_Custom_Picklist__c.Core_MDF_Market__c';

const _FIELDS = [RECORDTYPEID, ACTIVE_VERSION, ST_START_DATE, ST_END_DATE];

export default class Core_MDF_TargetSettingLineItemDataTable extends NavigationMixin(LightningElement) {
    @api recordId;
    columns = [];
    isEditable;
    ipaColumns = [];
    tableHeader;
    showSpinner = false;
    @track data = [];
    @track lineItemData;
    @track draftValues = [];
    lastSavedData = [];
    @track priorityOptions;
    @track bucketOptions;
    @track countryOptions;
    RecordType;
    RecordTypeId;
    lineItemsRecordTypeId;
    record;
    error;
    programName;
    totalRecords = 0; //Total no.of records
    pageSize = 10; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number    
    recordsToDisplay = []; //Records to be displayed on the page
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    spendingTargetsLineItems_Header;
    PRIORITY_WEIGHTAGE_RANGE_ERROR;
    PRIORITY_WEIGHTAGE_BLANK_ERROR;
    AMOUNT_NEGATIVE_ERROR;
    REGION_VALIDATION_ERROR;
    MULTI_COUNTRY_VALIDATION_ERROR;
    COUNTRY_NAME_BLANK_ERROR;
    CAMPAIGN_NAME_BLANK_ERROR;
    @track dataErrors = {};
    rowError = {};
    @track fieldSetName;
    @track campaignStatus;
    @track isCommunity;
    @track showTargetItemModal = false;
    @track showCreatedCampaign = false;
    @track showNewButton = false;
    @track isFieldEditable = false;


    //New
    @track recordIds;
    @track mode;
    @track cmpRecordTypeName;
    @track cmpRecordTypeDeveloperName;

    @track campaignName;
    @track countryListFromSTLI = [];
    selectedTargetLineItemSet = new Set();
    targetSLIIdToData = new Map();
    @track targetLineItemTable = [];
    cmpName = '';
    selectedCountryList = new Set();
    cmpAccountId = '';
    @track campaignFieldValue = {};
    campaignBudgetsForSave = [];
    @track pfrListCloneInsert = [];
    countryValue = '';
    priorityToPercentageMap = new Map();
    nonSimilarAccountSet = new Set();
    startDate;
    endDate;
    budgetType = '';
    smfIndicator = false;
    @track cmpRecordTypeId;
    cmpChannelProgram;
    isLoaded = false;
    countryGeoData = [];
    @track showCampaignButton = false;
    @track createBtnDisable = false;
    fieldNameForMetadataQuery = '';
    objectNameForMetadataQuery = '';
    whereClauseForMetadataQuery = '';
    label = { noSpendingItmAvaiable, campaignDateInPast, campaignDateBeyond2year };
    campPicklistValues = [];
    customPicklistRecordTypeId;
    @track startAndEndDateIsInPast = false;
    @track startAndEndDate2YearBelow = false;
    currentDate = new Date();
    spendingTargetId = '';
    @track validCountryPicklistListFromCPObject = [];
    customPicklistCCForDCFRecordTypeId;
    customPicklistObjectApiName;

    @wire(getConstants)
    allConstants({ data }) {
        if (data) {
            this.spendingTargetsLineItems_Header = data.SPENDING_TARGETS_LINE_ITEMS_HEADER;
            this.PRIORITY_WEIGHTAGE_RANGE_ERROR = data.PRIORITY_WEIGHTAGE_RANGE_ERROR;
            this.PRIORITY_WEIGHTAGE_BLANK_ERROR = data.PRIORITY_WEIGHTAGE_BLANK_ERROR;
            this.AMOUNT_NEGATIVE_ERROR = data.AMOUNT_NEGATIVE_ERROR;
            this.REGION_VALIDATION_ERROR = data.REGION_VALIDATION_ERROR;
            this.MULTI_COUNTRY_VALIDATION_ERROR = data.MULTI_COUNTRY_VALIDATION_ERROR;
            this.COUNTRY_NAME_BLANK_ERROR = data.COUNTRY_NAME_BLANK_ERROR;
            this.CAMPAIGN_NAME_BLANK_ERROR = data.CAMPAIGN_NAME_BLANK_ERROR;
            
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: _FIELDS })
    wiredRecord({ data, error }) {
        if (data) {
            this.record = data;
            this.spendingTargetId = this.record.fields.Core_MDF_Spending_Targets__r.value.id;
            this.RecordType = this.record.fields.Core_MDF_Spending_Targets__r.value.fields.RecordType.displayValue/*value.fields.DeveloperName.value*/;
            this.customPicklistObjectApiName = CUSTOM_PICKLIST_OBJECT;
            this.RecordTypeId = this.record.fields.Core_MDF_Spending_Targets__r.value.fields.RecordType.value.id;
            this.activeVersion = this.record.fields.Core_MDF_Is_Active_Ind__c;
            this.isEditable = this.activeVersion.value == true ? true : false;
            this.updateColumns();
            this.refreshData();
            this.startDate = this.record.fields.Core_MDF_Spending_Targets__r.value.fields.Core_MDF_Start_Date__c.value;
            this.endDate = this.record.fields.Core_MDF_Spending_Targets__r.value.fields.Core_MDF_End_Date__c.value;
            this.error = undefined;
            if (this.RecordType) {
                checkUserAccess({ channelProgram: this.RecordType })
                    .then(result => {
                        this.showCampaignButton = result.isCreateCampaignButtonAccess;
                        this.showNewButton = result.isNewButtonAccess;
                        if (this.isEditable && result.isEditAccess) {
                            this.isFieldEditable = true;
                        }
                        this.updateColumns();
                    })
                    .catch(error => {
                        console.error('Error fetching :', error);
                    });
            }
            fetchRecordTypeNames({ objectApiName: 'Core_MDF_ObjRecType_Budget_FieldSetMap__mdt', whereClause: `Core_MDF_Channel_Program_txt__c = '${this.RecordType}'` })
                .then(result => {
                    this.cmpRecordTypeDeveloperName = result[0].Core_MDF_Activity_RecordType_txt__c;
                    this.cmpChannelProgram = result[0].Core_MDF_Channel_Program_Name_txt__c;
                })
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    connectedCallback() {
        this.paginationHelper();
    }

    updateColumns() {
        this.columns = [
            {
                label: 'Spending Target Line Item Name', fieldName: 'NameLink', type: 'url', sortable: "true",
                typeAttributes: {
                    label: { fieldName: 'Name' },
                    target: '_blank'
                }
            },
            {
                label: 'Account', fieldName: 'AccLink', type: 'url', sortable: "true",
                typeAttributes: {
                    label: { fieldName: 'AccName' },
                    target: '_blank'
                }
            },
            {
                label: 'Priority', fieldName: 'Core_MDF_Priority_nm__c', type: 'picklistColumn', editable: this.isFieldEditable, sortable: "true",
                typeAttributes: {
                    options: { fieldName: 'priorityOptions' },
                    value: { fieldName: 'Core_MDF_Priority_nm__c' },
                    context: { fieldName: 'Id' },
                    placeholder: "Choose Priority"
                }
            },
            {
                label: 'Priority Weightage', fieldName: 'Core_MDF_Priority_Percentage__c', type: 'text', editable: this.isFieldEditable, sortable: "true",
                typeAttributes: {
                    step: '0.01',
                    maximumFractionDigits: '0'
                },
                cellAttributes: {
                    alignment: 'left'
                }
            },
            {
                label: 'Bucket', fieldName: 'Core_MDF_Bucket_nm__c', type: 'picklistColumn', editable: this.isFieldEditable, sortable: "true",
                typeAttributes: {
                    options: { fieldName: 'bucketOptions' },
                    value: { fieldName: 'Core_MDF_Bucket_nm__c' },
                    context: { fieldName: 'Id' },
                    placeholder: "Choose Bucket"
                }
            },
            {
                label: 'Country', fieldName: 'Core_MDF_Country_Name_nm__c', type: 'multiselectpicklistColumn', sortable: "true", initialWidth: 180,
                typeAttributes: {
                    options: { fieldName: 'countryOptions' },
                    value: { fieldName: 'Core_MDF_Country_Name_nm__c' },
                    context: { fieldName: 'Id' },
                    placeholder: "Choose Country",
                    editable: this.isEditable
                }
            },
            { label: 'Region', fieldName: 'Core_MDF_Region_Name_nm__c', type: 'picklist', sortable: "true" },
            {
                label: 'Amount', fieldName: 'Core_MDF_Amount__c', type: 'currency', editable: this.isFieldEditable, sortable: "true",
                cellAttributes: {
                    alignment: 'left'
                }
            },
            { label: 'Campaign Name', fieldName: 'Core_MDF_Campaign_Name__c', type: 'text', editable: this.isFieldEditable, sortable: "true" },
            {
                label: 'Campaign', fieldName: 'CampLink', type: 'url', sortable: "true",
                typeAttributes: {
                    label: { fieldName: 'CampName' },
                    target: '_blank'
                }
            }
        ];

    }
    @wire(fetchRecordTypeId, { RecordTypeName: '$RecordType', objectName: 'Campaign' })
    wiredCampaignRecordTypeId({ data, error }) {
        if (data) {
            this.cmpRecordTypeId = data.Id;
        }
    }

    @wire(getCountryGeoMap)
    countryGeo({ error, data }) {
        if (data) {
            this.countryGeoData = data;
        }
    }

    @wire(getObjectInfo, { objectApiName: "$customPicklistObjectApiName" }) wiredCustomPickListCCFRecordTypeId(objectInfo, error) {
        if (objectInfo) {
            let recordTypeInfo = objectInfo?.data?.recordTypeInfos;
            if (recordTypeInfo) {
                this.customPicklistCCForDCFRecordTypeId = Object.keys(recordTypeInfo).find(rtype => (recordTypeInfo[rtype].name === this.RecordType));
            }
        } else if (error) {
            this.showToast('Error fetching campaign record type', JSON.stringify(error), 'error', 'dismissable');
        }
    }
    
    @wire(getPicklistValues, { recordTypeId: "$customPicklistCCForDCFRecordTypeId", fieldApiName: CP_OBJ_COUNTRY_FIELD })
    wiredCPObjCountryPicklistValues({ error, data }) {
        if (data) {
            let countriesMap = data.values;
            this.validCountryPicklistListFromCPObject = countriesMap.map(country => country.label);

            this.countryGeoData = Object.keys(this.countryGeoData)
                .filter(country => this.validCountryPicklistListFromCPObject.includes(country))
                .reduce((obj, key) => {
                    obj[key] = this.countryGeoData[key];
                    return obj;
                }, {});
        } else if (error) {
            this.validCountryPicklistListFromCPObject = undefined;
            this.showToast('Error fetching valid countries', JSON.stringify(error), 'error', 'dismissable');
        }
    }

    getDataByGeo(geoValue) {
        var result = [];
        for (const countryKey in this.countryGeoData) {
            if (this.countryGeoData.hasOwnProperty(countryKey)) {
                const countryInfo = this.countryGeoData[countryKey];
                if (!countryInfo.blockInUI && countryInfo.geo === geoValue) {
                    if (countryInfo.allOtherAPJ && countryInfo.geo === 'APJ') {
                        result.push(countryInfo.country);
                    }
                    else if (countryInfo.allOtherASMO && countryInfo.geo === 'ASMO') {
                        result.push(countryInfo.country);
                    }
                    else if (countryInfo.allOtherEMEA && countryInfo.geo === 'EMEA') {
                        result.push(countryInfo.country);
                    }
                }
            }
        }
        return result;
    }

    @wire(getObjectInfo, { objectApiName: TARGET_SETTING_LINE_ITEM_OBJECT, recordType: '$RecordType' })
    objectInfo({ error, data }) {
        if (error) {
            // handle Error
        } else if (data) {
            const rtis = data.recordTypeInfos;
            this.lineItemsRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === this.RecordType); // to get the RecordType ID from RecordType Name of Parent record
        }
    };

    @wire(fetchRecordTypeId, { RecordTypeName: '$RecordType', objectName: 'Core_MDF_Custom_Picklist__c' })
    wiredCustomPickListRecordTypeId({ data, error }) {
        if (data) {
            this.customPicklistRecordTypeId = data.Id;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$customPicklistRecordTypeId', fieldApiName: CAMP_PRIORITY_FIELD })
    wiredCampPicklistValues({ error, data }) {
        if (data) {
            this.campPicklistValues = data.values;
        }
    }

    //fetch picklist options
    @wire(getPicklistValues, { recordTypeId: "$lineItemsRecordTypeId", fieldApiName: PRIORITY_FIELD })
    priorityPickList({ error, data }) {
        if (data) {
            this.priorityOptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$lineItemsRecordTypeId", fieldApiName: BUCKET_FIELD })
    bucketPickList({ error, data }) {
        if (data) {
            this.bucketOptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$lineItemsRecordTypeId", fieldApiName: COUNTRY_FIELD })
    countryPickList({ error, data }) {
        if (data) {
            this.countryOptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(fetchRecords, { recordId: '$recordId', priorityOptions: '$priorityOptions', bucketOptions: '$bucketOptions', countryOptions: '$countryOptions' })
    lineItemData(result) {
        this.lineItemData = result;
        if (result.data) {
            this.data = JSON.parse(JSON.stringify(result.data));

            this.data.forEach(element => {
                element.priorityOptions = this.priorityOptions;
                element.bucketOptions = this.bucketOptions;
                element.countryOptions = this.countryOptions;
                element.NameLink = '/' + element.Id; // to show Name as hyperlink
                if (element.Core_MDF_Account__c != null) {
                    element.AccLink = '/' + element.Core_MDF_Account__r.Id; // to show Account Name as hyperlink
                    element.AccName = element.Core_MDF_Account__r.Name;
                }
                if (element.Core_MDF_Priority_Percentage__c != null && element.Core_MDF_Priority_Percentage__c != undefined && element.Core_MDF_Priority_Percentage__c != '') {
                    element.Core_MDF_Priority_Percentage__c = element.Core_MDF_Priority_Percentage__c + '%';
                }
                if (element.Core_MDF_Campaign_Id__c != null) {
                    element.CampLink = '/' + element.Core_MDF_Campaign_Id__c;
                    element.CampName = element.Core_MDF_Campaign_Id__r.Name;
                }
                this.targetSLIIdToData.set(element.Id, element);
            })

            this.lastSavedData = JSON.parse(JSON.stringify(this.data));

            this.totalRecords = result.data.length; // update total records count
            this.paginationHelper(); // call helper menthod to update pagination logic 

        } else if (result.error) {
            this.data = undefined;
        }
    };

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        let dataError = {};

        //Error handling on UI for Priority Percentage field
        if (updateItem.Core_MDF_Priority_Percentage__c != null && updateItem.Core_MDF_Priority_Percentage__c != '' && updateItem.Core_MDF_Priority_Percentage__c != undefined) {
            var percentValue = 0;
            percentValue = updateItem.Core_MDF_Priority_Percentage__c;
            if (percentValue.includes("%")) {
                percentValue = percentValue.replace(/%/g, "");
            }
            updateItem.Core_MDF_Priority_Percentage__c = Math.round((percentValue) * 100) / 100;
            if (isNaN(updateItem.Core_MDF_Priority_Percentage__c) || (updateItem.Core_MDF_Priority_Percentage__c > 100 || updateItem.Core_MDF_Priority_Percentage__c < 0)) {
                if (Object.keys(this.dataErrors).length > 0 && this.dataErrors.rows.hasOwnProperty(updateItem.Id) && !this.dataErrors.rows[updateItem.Id].messages.includes(this.PRIORITY_WEIGHTAGE_RANGE_ERROR)) {
                    this.dataErrors.rows[updateItem.Id].messages.push(this.PRIORITY_WEIGHTAGE_RANGE_ERROR);
                    this.dataErrors.rows[updateItem.Id].fieldNames.push('Core_MDF_Priority_Percentage__c');
                }
                else {
                    this.rowError[updateItem.Id] = this.triggerError('Error', [this.PRIORITY_WEIGHTAGE_RANGE_ERROR], ['Core_MDF_Priority_Percentage__c']);
                    dataError['rows'] = this.rowError;
                    this.dataErrors = dataError;
                    updateItem.Core_MDF_Priority_Percentage__c = percentValue;
                }
            }
            else {
                updateItem.Core_MDF_Priority_Percentage__c = updateItem.Core_MDF_Priority_Percentage__c + '%';
                if (Object.keys(this.dataErrors).length > 0 && this.dataErrors.rows.hasOwnProperty(updateItem.Id) && this.dataErrors.rows[updateItem.Id].messages.length > 0) {
                    this.dataErrors.rows[updateItem.Id].messages = this.dataErrors.rows[updateItem.Id].messages.filter(item => item !== this.PRIORITY_WEIGHTAGE_RANGE_ERROR);
                    this.dataErrors.rows[updateItem.Id].messages = this.dataErrors.rows[updateItem.Id].messages.filter(item => item !== this.PRIORITY_WEIGHTAGE_BLANK_ERROR);
                    this.dataErrors.rows[updateItem.Id].fieldNames = this.dataErrors.rows[updateItem.Id].fieldNames.filter(item => item !== 'Core_MDF_Priority_Percentage__c');
                    if (this.dataErrors.rows[updateItem.Id].messages.length == 0) {
                        delete this.dataErrors.rows[updateItem.Id];
                    }
                }
            }
        }
        else if (updateItem.Core_MDF_Priority_Percentage__c == '') {

            if (Object.keys(this.dataErrors).length > 0 && this.dataErrors.rows.hasOwnProperty(updateItem.Id) && !this.dataErrors.rows[updateItem.Id].messages.includes(this.PRIORITY_WEIGHTAGE_BLANK_ERROR)) {
                this.dataErrors.rows[updateItem.Id].messages.push(this.PRIORITY_WEIGHTAGE_BLANK_ERROR);
                this.dataErrors.rows[updateItem.Id].fieldNames.push('Core_MDF_Priority_Percentage__c');
            }
            else {
                this.rowError[updateItem.Id] = this.triggerError('Error', [this.PRIORITY_WEIGHTAGE_BLANK_ERROR], ['Core_MDF_Priority_Percentage__c']);
                dataError['rows'] = this.rowError;
                this.dataErrors = dataError;
            }
        }

        //Error handling on UI for Amount field
        if (updateItem.Core_MDF_Amount__c != null && updateItem.Core_MDF_Amount__c != '' && updateItem.Core_MDF_Amount__c != undefined) {
            if (updateItem.Core_MDF_Amount__c < 0) {

                if (Object.keys(this.dataErrors).length > 0 && this.dataErrors.rows.hasOwnProperty(updateItem.Id) && !this.dataErrors.rows[updateItem.Id].messages.includes(this.AMOUNT_NEGATIVE_ERROR)) {
                    this.dataErrors.rows[updateItem.Id].messages.push(this.AMOUNT_NEGATIVE_ERROR);
                    this.dataErrors.rows[updateItem.Id].fieldNames.push('Core_MDF_Amount__c');
                }
                else {
                    this.rowError[updateItem.Id] = this.triggerError('Error', [this.AMOUNT_NEGATIVE_ERROR], ['Core_MDF_Amount__c']);
                    dataError['rows'] = this.rowError;
                    this.dataErrors = dataError;
                }
            }
            else {

                if (Object.keys(this.dataErrors).length > 0 && this.dataErrors.rows.hasOwnProperty(updateItem.Id) && this.dataErrors.rows[updateItem.Id].messages.length > 0) {
                    this.dataErrors.rows[updateItem.Id].messages = this.dataErrors.rows[updateItem.Id].messages.filter(item => item !== this.AMOUNT_NEGATIVE_ERROR);
                    this.dataErrors.rows[updateItem.Id].fieldNames = this.dataErrors.rows[updateItem.Id].fieldNames.filter(item => item !== 'Core_MDF_Amount__c');
                    if (this.dataErrors.rows[updateItem.Id].messages.length == 0) {
                        delete this.dataErrors.rows[updateItem.Id];
                    }
                }
            }

        }

        //Error handling on UI for Country Name field
        this.countryNameValidation(updateItem,dataError);
        
        //Error handling on UI for Campaign Name field
        this.campaignNameValidation(updateItem,dataError)


        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });

        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        //this.updateDraftValues(event.detail.draftValues[0]);
        let draftValues = event.detail.draftValues;
        draftValues.forEach(ele => {
            this.updateDraftValues(ele);
        })
    }

    handleSave(event) {
        this.showSpinner = true;
        this.saveDraftValues = this.draftValues;

        if (this.dataErrors !== {} && Object.keys(this.dataErrors).length > 0 && Object.keys(this.dataErrors.rows).length > 0) {
            this.showToast('Error', 'Review errors on page', 'error', 'dismissable');
            return;
        }

        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
 
        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.showToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.draftValues = [];
            return this.refresh();
        }).catch(error => {
            console.log(error);
            this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');
        }).finally(() => {
            this.draftValues = [];
            this.showSpinner = false;
        });
    }

    handleCancel(event) {
        //remove draftValues & revert data changes
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
        this.rowError = {};
        this.dataErrors = {};
    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    // This function is used to refresh the table once data updated
    async refresh() {
        await refreshApex(this.lineItemData);
    }

    handleCreate(event) {

        // code to default the Spending Targets Version id on click of new button 
        const defaultValues = encodeDefaultFieldValues({
            Core_MDF_Spending_Targets_Version__c: this.recordId
        });

        //Standard new button of Target Setting Line Item and on clik of save button stay on the same page
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Core_MDF_Target_Setting_Line_Item__c',
                actionName: 'new'

            },
            state: {
                defaultFieldValues: defaultValues,
                navigationLocation: 'RELATED_LIST',
                backgroundContext: '/lightning/r/Core_MDF_Spending_Targets_Version__c/' + this.recordId + '/view',
                recordTypeId: this.lineItemsRecordTypeId
            }
        });
    }

    refreshData() {
        refreshApex(this.lineItemData);
    }

    /****************************** Pagination Code *********************************/

    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }

    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.data[i]);
        }
    }
    /************************************Pagination Code End***************************************/

    /************************************Sorting Code***************************************/

    onHandleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortedBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        // Return the value stored in the field
        let keyValue = (value) => {
            return value[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
        this.paginationHelper();
    }

    /************************************Sorting Code End***************************************/

    triggerError(title, messages, fieldNames) {
        let rowError = {};
        rowError['title'] = title;
        rowError['messages'] = messages;
        rowError['fieldNames'] = fieldNames;
        return rowError;
    }
    handleCreateCampaign(event) {
        this.startAndEndDate2YearBelow = false;
        var accountToData = [];
        accountToData = this.data.reduce((acc, item) => {
            if (this.campPicklistValues.some(val => val.value === item.Core_MDF_Priority_nm__c)) {
                if (!item.Core_MDF_Campaign_Id__c && item.Core_MDF_Account__r.Core_MDF_Active_Ind__c) {
                    if (!acc[item.Core_MDF_Account__r.Name]) {
                        acc[item.Core_MDF_Account__r.Name] = [];
                    }
                    acc[item.Core_MDF_Account__r.Name].push(item);
                }
            }
            return acc;
        }, {});
        this.targetLineItemTable = Object.keys(accountToData).map((key) => ({
            key: key,
            value: accountToData[key]
        }));
        this.targetLineItemTable.sort((a, b) => (a.key > b.key) ? 1 : -1);
        if (this.targetLineItemTable.length === 0) {
            this.createBtnDisable = true;
        } else {
            this.createBtnDisable = false;
        }
        const todaysDate = this.currentDate.toISOString().slice(0, 10);
        if (this.endDate < todaysDate) {
            this.startAndEndDateIsInPast = true;
            this.createBtnDisable = true;
        }
        const startDt = new Date(this.startDate);
        const twoYearsFromStartDt = new Date(startDt.getFullYear() + 2, startDt.getMonth(), startDt.getDate());
        const twoYearsFromSTDate = twoYearsFromStartDt.toISOString().slice(0, 10);
        if (this.endDate > twoYearsFromSTDate) {
            this.startAndEndDate2YearBelow = true;
            this.createBtnDisable = true;
        }

        this.showTargetItemModal = true;
    }
    closeTargetItemModal() {
        this.showTargetItemModal = false;
        this.selectedTargetLineItemSet.clear();
    }
    getCampaignFieldsValues() {
        this.campaignFieldValue["Name"] = this.cmpName;
        this.campaignFieldValue["Core_MDF_Program__c"] = this.cmpChannelProgram;
        this.campaignFieldValue["RecordTypeId"] = this.cmpRecordTypeId;
        this.campaignFieldValue["Core_MDF_Account__c"] = this.cmpAccountId;
        this.campaignFieldValue["Core_MDF_Market__c"] = this.countryValue;
        this.campaignFieldValue["StartDate"] = this.startDate;
        this.campaignFieldValue["EndDate"] = this.endDate;
        this.campaignFieldValue["Status"] = 'Draft';
        this.campaignFieldValue["Core_MDF_Strategic_Marketing_Fund_Ind__c"] = this.smfIndicator;
        this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] = this.budgetType;
        this.campaignFieldValue["Core_MDF_Campaign_Source_nm__c"] = 'Target Setting';
        this.campaignFieldValue["Core_MDF_Spending_Targets_Id__c"] = this.spendingTargetId;
        this.campaignFieldValue["Core_MDF_Reimbursement_Rate__c"] = '';
        if (this.priorityToPercentageMap.size > 0) {
            const sortedPriToPct = Array.from(this.priorityToPercentageMap.entries()).sort((a, b) => {
                const valueComparison = parseFloat(b[1]) - parseFloat(a[1]); // Sort by values in descending order
                if (valueComparison !== 0) {
                    return valueComparison;
                }
                return a[0].localeCompare(b[0]);
            });
            if (sortedPriToPct.length < 2) {
                this.campaignFieldValue["Core_MDF_Priority__c"] = sortedPriToPct[0][0];
                this.campaignFieldValue["Core_MDF_Priority_Percentage__c"] = sortedPriToPct[0][1];
            }
            else if (sortedPriToPct.length < 3) {
                this.campaignFieldValue["Core_MDF_Priority__c"] = sortedPriToPct[0][0];
                this.campaignFieldValue["Core_MDF_Priority_2_nm__c"] = sortedPriToPct[1][0];
                this.campaignFieldValue["Core_MDF_Priority_Percentage__c"] = sortedPriToPct[0][1];
                this.campaignFieldValue["Core_MDF_Priority_Percentage_2__c"] = sortedPriToPct[1][1];
            }
            else {
                this.campaignFieldValue["Core_MDF_Priority__c"] = sortedPriToPct[0][0];
                this.campaignFieldValue["Core_MDF_Priority_2_nm__c"] = sortedPriToPct[1][0];
                this.campaignFieldValue["Core_MDF_Priority_3_nm__c"] = sortedPriToPct[2][0];
                this.campaignFieldValue["Core_MDF_Priority_Percentage__c"] = sortedPriToPct[0][1];
                this.campaignFieldValue["Core_MDF_Priority_Percentage_2__c"] = sortedPriToPct[1][1];
                this.campaignFieldValue["Core_MDF_Priority_Percentage_3__c"] = sortedPriToPct[2][1];
            }
        }
        if ((this.budgetType.includes('OEM CMP') || this.budgetType.includes('Service Provider CMP')) && !this.budgetType.includes('MDF') && !this.budgetType.includes('MDF+')) {
            this.campaignFieldValue["Core_MDF_Supports_legacy_program__c"] = 'CMP only';
        } else {
            this.campaignFieldValue["Core_MDF_Supports_legacy_program__c"] = 'MDF or both CMP & MDF';
        }
        // Only OEM CMP // based on Budget Type
        // this.campaignFieldValue["Core_MDF_Account__c"] = 

        return this.campaignFieldValue;
    }

    handleCreateCampFromSTLI(event) {
        this.countryValue = '';
        var selectedTargetLineItemId = new Set();
        // if(this.accountSet.size === 1){
        var countries = [];
        if (this.selectedTargetLineItemSet.size === 0) {
            this.showToast('Error Message', selectOneTargetItem, 'error', 'dismissable');

        }
        else if (this.nonSimilarAccountSet.size === 0 && this.selectedTargetLineItemSet.size > 0) {
            if (!this.startAndEndDate2YearBelow) {
                this.addCountriesToList();
                this.selectedCountryList.forEach(field => {
                    countries.push(this.getCountries(field));
                });
                if (countries) {
                    let flattenedCountries = countries.flat();
                    //this.countryValue = countries;
                    //const countriesArray = countries.split(';').filter(country => country.trim() !== '');
                    // var country = flattenedCountries.slice(0, 100);
                    this.countryValue = flattenedCountries.join(';');
                    let countrySet = new Set(this.countryValue.split(';'));
                    let uniqueCountryList = Array.from(countrySet);
                    let countryList = uniqueCountryList.slice(0,100);
                    this.countryValue = countryList.join(';');
                }
                // this.getCampaignFieldsValues();
                // this.showCreatedCampaign = true;
                // this.recordIds = '701Dx000000lPjMIAU';
                if (this.countryValue) {
                    this.isLoaded = true;
                    saveCampaign({ campaignObj: this.getCampaignFieldsValues(), campaignBudgets: this.campaignBudgetsForSave, pfrList: this.pfrListCloneInsert, campAmountFields: "",
                        selectedActPartners: '', contractLineItemRecordsToSave: null, outcomeWrapperList: null, activityToActivityAttrWrapperList: null, hasTacticMetrics: false })
                        .then(result => {
                            if (result) {
                                this.recordIds = result;
                                this.showCreatedCampaign = true;

                                this.selectedTargetLineItemSet.forEach(field => {
                                    selectedTargetLineItemId.add(field.Id);
                                });
                                if (this.recordIds) {
                                    var idList = Array.from(selectedTargetLineItemId);
                                    updateCmpIdToSTLI({ selectedLineItmIdList: idList, campaignId: result })
                                        .then(data => {
                                            console.log('@@updateCmpIdToSTLI Data-> ', data);
                                        })
                                        .catch(error => {
                                            console.log("error", error);
                                        })
                                }
                            }
                        })
                        .catch(error => {
                            this.showToast('Error', applicationError, 'error', 'dismissable');
                            this.isLoaded = false;
                        })

                }
            }
        }
        else {
            this.showToast('Error Message', selectOneAccLabel, 'error', 'dismissable');
        }

        this.mode = 'edit';
        this.campaignStatus = 'Draft';
        this.cmpRecordTypeName = this.RecordType;

        getRTFieldSet({ objectName: 'Campaign', recordTypeDeveloperName: this.cmpRecordTypeDeveloperName })
            .then(data => {
                this.fieldSetName = data;
            })
            .catch(error => {
                this.showToast('Error', applicationError, 'error', 'dismissable');
                this.isLoaded = false;
            })
    }
    closeCampaignWindow(event) {
        this.showCreatedCampaign = false;
        this.countryListFromSTLI = [];
        this.campaignName = '';
        this.countryValue = '';
        this.selectedCountryList.clear();
        location.reload();
    }

    handleTargetLineItemCheckbox(event) {
        const value = event.target.dataset.id;
        let campName = '';
        let campAccId = '';
        var smfIndSet = new Set();
        var budgetTypeSet = new Set();
        this.nonSimilarAccountSet.clear();
        this.selectedCountryList.clear();
        this.budgetType = '';
        this.smfIndicator = false;
        this.priorityToPercentageMap.clear();
        if (event.target.checked) {
            this.selectedTargetLineItemSet.add(this.targetSLIIdToData.get(value));
        }
        else if (!event.target.checked) {
            this.selectedTargetLineItemSet.delete(this.targetSLIIdToData.get(value));
        }
        let selectedItemArray = Array.from(this.selectedTargetLineItemSet);

        if (selectedItemArray.length > 0 && selectedItemArray !== null) { // check with return of selectedItemArray
            for (let i = 0; i < selectedItemArray.length; i++) {
                if (selectedItemArray[0].Core_MDF_Account__c !== selectedItemArray[i].Core_MDF_Account__c) {
                    this.nonSimilarAccountSet.add(selectedItemArray[i].Core_MDF_Account__c);
                }
                else {
                    campName += selectedItemArray[i].Core_MDF_Campaign_Name__c;
                    this.selectedCountryList.add(selectedItemArray[i].Core_MDF_Country_Name_nm__c);
                    //this.addCountriesToList(selectedItemArray[i].Core_MDF_Country_nm__c); //
                    campAccId = selectedItemArray[0].Core_MDF_Account__c; // don't dirclty access 0 index
                    smfIndSet.add(selectedItemArray[i].Core_MDF_Bucket_nm__c);
                    budgetTypeSet.add(selectedItemArray[i].Core_MDF_Budget_Type_nm__c);
                }
                let originalMap = new Map();
                let priorityPer;
                if (selectedItemArray[i].Core_MDF_Priority_Percentage__c === 0) {
                    priorityPer = selectedItemArray[i].Core_MDF_Priority_Percentage__c;
                }
                else {
                    priorityPer = parseFloat(selectedItemArray[i].Core_MDF_Priority_Percentage__c.replace('%', ''));
                }
                originalMap.set(selectedItemArray[i].Core_MDF_Priority_nm__c, priorityPer);
                this.priorityMapCreation(originalMap);
            }
        }
        if (smfIndSet.size > 0) {
            if (smfIndSet.has('SMF')) {
                this.smfIndicator = true;
            }
        }
        if (budgetTypeSet.size > 0) {
            budgetTypeSet.forEach(field => {
                this.budgetType += field + ';';
            });
        }

        if (campName.length > 80) {
            campName = campName.substring(0, 80);
        }

        this.cmpName = campName;
        this.cmpAccountId = campAccId;
    }

    priorityMapCreation(priorityMap) {
        for (const [key, value] of priorityMap.entries()) {
            if (!this.priorityToPercentageMap.has(key) || value > this.priorityToPercentageMap.get(key)) {
                this.priorityToPercentageMap.set(key, value);
            }
        }
    }

    addCountriesToList() {
        let elementsToMove = [];
    
        this.selectedCountryList.forEach(value => {
        if (value.startsWith("All Other")) {
                elementsToMove.push(value);
            }
        });
        
        elementsToMove.forEach(element => {
            if (this.selectedCountryList.has(element)) {
                this.selectedCountryList.delete(element);
            }
        });


        elementsToMove.forEach(element => {
            this.selectedCountryList.add(element);
        });
    }


    getCountries(selectedCountry){
        var country;;
        if (selectedCountry === 'All Other ASMO') {
            country = this.getDataByGeo('ASMO');
        }
        else if (selectedCountry === 'All Other EMEA') {
            country = this.getDataByGeo('EMEA');
        }
        else if (selectedCountry === 'All Other APJ') {
            country = this.getDataByGeo('APJ');
        }
        else {
            country = selectedCountry;
        }
        return country;
    }

    multpicklistChanged(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem = { Id: dataRecieved.context, Core_MDF_Country_Name_nm__c: dataRecieved.value};
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.data));
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
        //write changes back to original data
        this.data = [...copyData];
    }

    //Error handling on UI for Country Name field
    countryNameValidation(updateItem,dataError){
        if (updateItem.Core_MDF_Country_Name_nm__c != null && updateItem.Core_MDF_Country_Name_nm__c != '' && updateItem.Core_MDF_Country_Name_nm__c != undefined) {
            validateUserRegion({ recordId: updateItem.Id, country: updateItem.Core_MDF_Country_Name_nm__c })
                .then(data => {
                    if (data) {
                        if (Object.keys(this.dataErrors).length > 0 && this.dataErrors.rows.hasOwnProperty(updateItem.Id) && !this.dataErrors.rows[updateItem.Id].messages.includes(this.REGION_VALIDATION_ERROR)) {
                            this.dataErrors.rows[updateItem.Id].messages.push(this.REGION_VALIDATION_ERROR);
                            this.dataErrors.rows[updateItem.Id].fieldNames.push('Core_MDF_Country_Name_nm__c');
                        }
                        else {
                            this.rowError[updateItem.Id] = this.triggerError('Error', [this.REGION_VALIDATION_ERROR], ['Core_MDF_Country_Name_nm__c']);
                            dataError['rows'] = this.rowError;
                            this.dataErrors = dataError;
                        }
                    }

                    else {
                        if (Object.keys(this.dataErrors).length > 0 && this.dataErrors.rows.hasOwnProperty(updateItem.Id) && this.dataErrors.rows[updateItem.Id].messages.length > 0) {
                            this.dataErrors.rows[updateItem.Id].messages = this.dataErrors.rows[updateItem.Id].messages.filter(item => item !== this.REGION_VALIDATION_ERROR);
                            this.dataErrors.rows[updateItem.Id].fieldNames = this.dataErrors.rows[updateItem.Id].fieldNames.filter(item => item !== 'Core_MDF_Country_Name_nm__c');
                            if (this.dataErrors.rows[updateItem.Id].messages.length == 0) {
                                delete this.dataErrors.rows[updateItem.Id];
                                this.dataErrors = {...this.dataErrors};
                            }
                        }
                    }
                    //this.dataErrors = {...this.dataErrors};
                })
                .catch(error => {
                    console.log("error", error);
                })

                var countryList = updateItem.Core_MDF_Country_Name_nm__c.split(';');
                if (countryList.length > 1 && (countryList.includes('All Other APJ') 
                    || countryList.includes('All Other EMEA') || countryList.includes('All Other ASMO'))) {

                    if (Object.keys(this.dataErrors).length > 0 && this.dataErrors.rows.hasOwnProperty(updateItem.Id) && !this.dataErrors.rows[updateItem.Id].messages.includes(this.MULTI_COUNTRY_VALIDATION_ERROR)) {
                        this.dataErrors.rows[updateItem.Id].messages.push(this.MULTI_COUNTRY_VALIDATION_ERROR);
                        this.dataErrors.rows[updateItem.Id].fieldNames.push('Core_MDF_Country_Name_nm__c');
                    }
                    else {
                        this.rowError[updateItem.Id] = this.triggerError('Error', [this.MULTI_COUNTRY_VALIDATION_ERROR], ['Core_MDF_Country_Name_nm__c']);
                        dataError['rows'] = this.rowError;
                        this.dataErrors = dataError;
                    }
                }
                else {
    
                    if (Object.keys(this.dataErrors).length > 0 && this.dataErrors.rows.hasOwnProperty(updateItem.Id) && this.dataErrors.rows[updateItem.Id].messages.length > 0) {
                        this.dataErrors.rows[updateItem.Id].messages = this.dataErrors.rows[updateItem.Id].messages.filter(item => item !== this.MULTI_COUNTRY_VALIDATION_ERROR);
                        this.dataErrors.rows[updateItem.Id].messages = this.dataErrors.rows[updateItem.Id].messages.filter(item => item !== this.COUNTRY_NAME_BLANK_ERROR);
                        this.dataErrors.rows[updateItem.Id].fieldNames = this.dataErrors.rows[updateItem.Id].fieldNames.filter(item => item !== 'Core_MDF_Country_Name_nm__c');
                        if (this.dataErrors.rows[updateItem.Id].messages.length == 0) {
                            delete this.dataErrors.rows[updateItem.Id];
                        }
                    }
                }
        }
        else if (updateItem.Core_MDF_Country_Name_nm__c == '') {
            //if Country Name Field is blank show the below error
            if (Object.keys(this.dataErrors).length > 0 && this.dataErrors.rows.hasOwnProperty(updateItem.Id) && !this.dataErrors.rows[updateItem.Id].messages.includes(this.COUNTRY_NAME_BLANK_ERROR)) {
                this.dataErrors.rows[updateItem.Id].messages.push(this.COUNTRY_NAME_BLANK_ERROR);
                this.dataErrors.rows[updateItem.Id].fieldNames.push('Core_MDF_Country_Name_nm__c');
            }
            else {
                this.rowError[updateItem.Id] = this.triggerError('Error', [this.COUNTRY_NAME_BLANK_ERROR], ['Core_MDF_Country_Name_nm__c']);
                dataError['rows'] = this.rowError;
                this.dataErrors = dataError;
            }
        }
    }

    //Error handling on UI for Campaign Name field
    campaignNameValidation(updateItem,dataError){
        if (updateItem.Core_MDF_Campaign_Name__c != null && updateItem.Core_MDF_Campaign_Name__c != '' && updateItem.Core_MDF_Campaign_Name__c != undefined) {
            //if Campaign Name Field is not blank remove the below error
            if (Object.keys(this.dataErrors).length > 0 && this.dataErrors.rows.hasOwnProperty(updateItem.Id) && this.dataErrors.rows[updateItem.Id].messages.length > 0) {
                this.dataErrors.rows[updateItem.Id].messages = this.dataErrors.rows[updateItem.Id].messages.filter(item => item !== this.CAMPAIGN_NAME_BLANK_ERROR);
                this.dataErrors.rows[updateItem.Id].fieldNames = this.dataErrors.rows[updateItem.Id].fieldNames.filter(item => item !== 'Core_MDF_Campaign_Name__c');
                if (this.dataErrors.rows[updateItem.Id].messages.length == 0) {
                    delete this.dataErrors.rows[updateItem.Id];
                }
            }
        }
        else if(updateItem.Core_MDF_Campaign_Name__c == '') { //if Campaign Name Field is blank show the below error
            if (Object.keys(this.dataErrors).length > 0 && this.dataErrors.rows.hasOwnProperty(updateItem.Id) && !this.dataErrors.rows[updateItem.Id].messages.includes(this.CAMPAIGN_NAME_BLANK_ERROR)) {
                this.dataErrors.rows[updateItem.Id].messages.push(this.CAMPAIGN_NAME_BLANK_ERROR);
                this.dataErrors.rows[updateItem.Id].fieldNames.push('Core_MDF_Campaign_Name__c');
            }
            else {
                this.rowError[updateItem.Id] = this.triggerError('Error', [this.CAMPAIGN_NAME_BLANK_ERROR], ['Core_MDF_Campaign_Name__c']);
                dataError['rows'] = this.rowError;
                this.dataErrors = dataError;
            }
        }
    }
}