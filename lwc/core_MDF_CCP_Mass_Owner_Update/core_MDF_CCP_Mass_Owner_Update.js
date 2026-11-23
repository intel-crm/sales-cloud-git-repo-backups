import { track, wire, LightningElement, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAppData from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getAppValues';
import getAccounts from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getAccounts';
import getNodeAccounts from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getAccountNodes';
import getUser from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getUser';
import getObjectTransactions from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getObjectTransactions';
import getToUser from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getToUser';
import updateOwner from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.updateOwner';
import getFilterFieldList from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getFilterFieldList';
import getFilterFieldWrapper from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getFilterFieldWrapper';
import getDynamicColumnHeaders from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getDynamicColumnHeaders';
import getDashboardData from '@salesforce/apex/CRM_Create_Dashbord_detail.Create_Dasboard_Data';
//custom labels
import programLabel from '@salesforce/label/c.Core_MDF_Program';
import accountLabel from '@salesforce/label/c.Core_MDF_Channel_Partner';
import nodeaccountLabel from '@salesforce/label/c.Core_MDF_Account_Node';
import selectProgram from '@salesforce/label/c.Core_MDF_LWC_SelectProgram_Label';
import selectAccount from '@salesforce/label/c.Core_MDF_LWC_SelectAccount_Label';
import getDataLabel from '@salesforce/label/c.Core_MDF_GetData';
import testDateChange from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.testDateChange'
//import resetToDefault from '@salesforce/label/c.Core_MDF_ResetToDefault';



export default class Core_MDF_CCP_Mass_Owner_Update extends LightningElement {
    massOwnerMdtList;
    isProgramApplicable = false;
    showTypeOfFromUser = false;
    showIntelAccount = false;
    disbaleNodeAccount = true;
    disableProgram = false;
    disableObject = false;
    disableApp = false;
    showGetData = false;
    @track accountValueSelected = '';
    @track nodeAccountValueSelected = '';
    @track programValueSelected = '';
    @track objectValueSelected = '';
    @track allOptionsNotSelected = true;
    @track showTransactionDetails = false;
    @track selectedIds = [];
    @track selectedIdsNew = [];
    @track valueselected;
    @track recId;
    @track showToUser = false;
    @track showFromUser = false;
    @track show = false;
    @track showAccountOptions = false;
    @track ownerSelected = [];
    @track objRecordsList = [];
    @track objRecordsListcount = 0;
    @track hasRecords;
    @track appSelected = '';
    @track messageFlagNew = false;
    @track toUserList = [];
    @track ownerSelectedNew = [];
    @track recIdNew;
    @track ownerName = [];
    @track messageFlag = false;
    @track dynamiClassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
    @track dynamiClassnamenew = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
    @track valueselectedNew;
    @track accountName = '';
    @track showUpdateOwnershipButton = false;
    @track nodeAccountName = '';
    @track disableFromUser = false;
    @track showProgram = false;
    @api item = { data: null, errors: null };
    @track fromUserTypeSelected = '';
    @track selectedObjectLabel = '';
    @track isCRMPlatform = false;
    @track fromUserSelected = false;
    @track crmSelObj = '';
    @track startDateSelected;
    @track endDateSelected;
    disableUpdateOwnershipButton = false;
    records = '';
    programOptions = [];
    accountOptions = [];
    nodeAccountOptions = [];
    objectOptions = [];
    programOpt = [];
    appOptions = [];
    selectedRowIds = [];
    newselectedRowIds = [];
    fromUserOptions = [];
    toUserOptions = []
    toUserTypeSelected;
    programLabel = programLabel;
    accountLabel = accountLabel;
    selectProgram = selectProgram;
    selectAccount = selectAccount;
    nodeaccountLabel = nodeaccountLabel;
    getDataLabel = getDataLabel;
    resetToDefault = 'Reset';
    programSelected = '';
    accountSelected = '';
    objectSelected = '';
    nodeAccountSelected = '';
    typeOfFromUser = '';
    typeofToUser = '';
    fromUserName = '';
    toUserName = '';
    isInternalUser = false;
    isPartnerUser = false;
    disableGetData = true;
    disableAccountOptions = false;
    showToUserDropdown = false;
    disableToUserDropdown = false;
    recordsList;
    updatedRecordList = [];
    showOwnershipUpdatedRecords = false;
    accountQueryFilter = 'Core_Account_Record_Type__c=\'Intel Account\' and Core_MDF_CoMarketingActive__c=true WITH SECURITY_ENFORCED order by Name asc';
    typeOfFromUserConst = ['External User', 'Internal User', 'System User'];
    typeOfToUserConst = ['External User', 'Internal User'];
    showSpinner = false;
    programOptionsList = [];
    objectOptionsList = [];
    @track filterFieldList = [];
    //filterFieldOptionsList = [];
    crmObjectData = [];
    filterFieldApplicable = false;
    @track filterCriteria = [];
    @track filterCriteriaLabel = '';
    @track filterCriteriaJsonString = '';
    columnHeaders = [];
    comboboxData = [];
    objectMdtList = [];
    filterFieldDropdown = [];
    filterFieldDate = [];
    filterFieldText = [];
    filterDateFieldValue = {};
    picklistFiltFldValueToApex = [];
    dateFiltFldValueToApex = [];
    textFiltFldValueToApex = [];
    filterFieldsWrapper = {};
    @track sectionData = {};
    @track showCRMTransactions = false;
    @track isFilterFieldApplicale = false;
    objMdtRec = {};
    selectedSampleDate;
    @track isReportsOrDashboards = false;
    /*@wire(getObjectTransactions, { program: '$programValueSelected', objectname: '$objectValueSelected', accountId: '$nodeAccountValueSelected', user: '$valueselected', typeOfUser: '$typeOfFromUser', filterCriteria: '$filterCriteria', startDate: '$startDateSelected', endDate: '$endDateSelected', filterFieldsWrapper:  '$filterFieldsWrapper', selectedIds: [] })
    wiredCampaigns(response) {
        const data = response.data;
        const error = response.error;
        this.recordsList = response;
        console.log('responce in wire', response);
        console.log('valueselected', this.valueselected);
        console.log('157 programValueSelected', this.programValueSelected);
        console.log('158 objectValueSelected', this.objectValueSelected);
        console.log('159 accId', this.nodeAccountValueSelected);
        console.log('160 typeOfFromUser', this.typeOfFromUser);
        console.log('object data', data);
        console.log('recordsList', this.recordsList);
        console.log('filterCriteria', this.filterCriteria);
        console.log('filterFieldsWrapper',this.filterFieldsWrapper);
        if (data) {
            console.log('campaign data', data);
            this.records = data;
            console.log('records', this.records);
            let result = [];
            result = this.getformattedData(data);

            console.log('result in wire', result);
            this.objRecordsList = [...result];
            console.log('objRecordsList in wire', this.objRecordsList);
            this.objRecordsListcount = this.objRecordsList.length;
            console.log('this.objRecordsListcount' + this.objRecordsListcount);
            this.hasRecords = this.objRecordsListcount > 0 ? true : false;
        }
        else if (error) {
            console.log('error', error);
            this.error = error;
        }
    }*/
    connectedCallback() {
        this.getApp();
    }
    getApp() {
        getAppData()
            .then((data) => {
                console.log('data', data);
                if (this.checkForUndefinedEmptyAndNull(data) && data !== {}) {
                    this.massOwnerMdtList = data.mdtList;
                    console.log('massOwnerMdtList', this.massOwnerMdtList);
                    this.appOptions = data.applicationList;
                    console.log('210 this.appOptions', this.appOptions);
                    //this.programOptionsList = data.programList;
                    //console.log('programOptionsList',this.programOptionsList);
                    //this.objectOptionsList = data.objectList;
                    //console.log('objectOptions',this.objectOptionsList);
                    //console.log('app options', this.appOptions);
                    //this.filterFieldList = data.filterFieldList;
                    //console.log('filterFielfOptions', this.filterFieldList);
                }
            })
            .catch(error => {
                this.error = error;
            });
    }
    get dynamiccolumns() {
        return this.columnHeaders.map(header => {
            return {
                label: header,    // The column header text
                fieldName: header.replace(/\s+/g, ''), // The field name (matches the data keys)
                type: 'text',
                sortable: true,
                disabled: false,
            };
        });
    }


    handleAppFilterChange(event) {
        this.showFromUser = false;
        let selectedPlatform = event.target.value;
        console.log('app selected', selectedPlatform);
        if (selectedPlatform == 'CRM') {
            this.isCRMPlatform = true;
            this.nodeAccountValueSelected = null;
            //this.isFilterFieldApplicale = true;
        }
        else {
            this.isCRMPlatform = false;
            this.disableProgram = false;
            this.disableObject = false;
            this.filterFieldApplicable = false;
            this.isFilterFieldApplicale = false;
        }
        let programOptionsList = [];
        let mdtIndex = this.massOwnerMdtList.findIndex(mdt => mdt.Core_MDF_App__c === selectedPlatform);
        let isProgramApplicable = this.massOwnerMdtList[mdtIndex].Core_MDF_isProgramApplicable__c;
        let massOwnerMdtList = this.massOwnerMdtList;
       
        if (isProgramApplicable) {
            this.massOwnerMdtList.forEach(mdt => {
                if (mdt.Core_MDF_App__c === selectedPlatform) {
                    console.log('program', mdt.Core_MDF_Program__c);
                    const existingFieldIndex = this.programOptions.findIndex(item => item.label === mdt.Core_MDF_Program__c);
                    if(existingFieldIndex == -1){
                    this.programOptions.push({ label: mdt.Core_MDF_Program__c, value: mdt.Core_MDF_Program__c });
                    }
                    //this.programOptions = this.programOptionsList;
                }
            });
            // this.programOptions = this.programOptionsList;
            console.log('programOptions', this.programOptions);
        }
        this.programOptions.sort((a, b) => a.label.localeCompare(b.label));
        this.isProgramApplicable = isProgramApplicable;
        this.appSelected = selectedPlatform;
        let objectOptions = [];
        if (this.appSelected == 'CRM') {
            massOwnerMdtList.forEach(mdt => {
                if (mdt.Core_MDF_App__c === this.appSelected) {
                    objectOptions.push({ label: mdt.Core_MDF_Object_Label__c, value: mdt.Core_MDF_Object__c, records: [] });
                    let filterVal = mdt.Core_MDF_Filter_Criteria__c != null ? mdt.Core_MDF_Filter_Criteria__c : '';
                    this.objectMdtList.push({ apiName: mdt.Core_MDF_Object__c, value: mdt, filterVal: filterVal });
                }

            });
            console.log('objectMdtList', this.objectMdtList);
            this.objectOptions = objectOptions;
            this.objectOptions.sort((a, b) => a.label.localeCompare(b.label));
            this.objectOptions = this.objectOptions.sort();
            //this.showTypeOfFromUser = true;
            this.filterFieldApplicable = true;
        }
        else {
            this.objectOptions = []
            //this.showTypeOfFromUser = false;
            this.filterFieldApplicable = false;
        }
        console.log('object options at line 261', this.objectOptions);
        console.log('filterField', this.filterFieldApplicable);
        if (this.appSelected != null) {
            this.disableApp = true;
        }
    }

    handleProgramFilterChange(event) {
        this.programValueSelected = event.target.value;
        this.showTypeOfFromUser = true;
        if (this.programValueSelected != null) {
            this.disableProgram = true;
        }      
        console.log('242 program selected', this.programValueSelected);

        let massOwnerMdtList = this.massOwnerMdtList;
        console.log('line 240', massOwnerMdtList);
        let objectOptions = [];
        massOwnerMdtList.forEach(mdt => {
            if (mdt.Core_MDF_App__c === this.appSelected && mdt.Core_MDF_Program__c === this.programValueSelected) {
                objectOptions.push({ label: mdt.Core_MDF_Object_Label__c, value: mdt.Core_MDF_Object__c });
                let filterVal = mdt.Core_MDF_Filter_Criteria__c != null ? mdt.Core_MDF_Filter_Criteria__c : '';
                this.objectMdtList.push({ apiName: mdt.Core_MDF_Object__c, value: mdt, filterVal: filterVal});
            }

        });
        
        console.log('objectOptions', objectOptions);
        console.log('objectMdtList', this.objectMdtList);
        this.objectOptions = objectOptions;
        this.objectOptions.sort((a, b) => a.label.localeCompare(b.label));
        this.objectOptions = this.objectOptions.sort();

    }

    handleobjectFilterChange(event) {
        console.log('object selected', event);
        this.objectValueSelected = event.target.value;
        console.log('at 393', event.target.value);
        if( this.objectValueSelected == 'Reports' ||  this.objectValueSelected == 'Dashboards'){
            this.isReportsOrDashboards = true;
            this.showToUserDropdown = true;
            this.isInternalUser = true;
            this.showFromUser = true;
        }
    
        let objInd = this.objectOptions.findIndex(obj => obj.value == this.objectValueSelected);
        this.selectedObjectLabel = this.objectOptions[objInd].label;
        console.log('selectedObjectLabel', this.selectedObjectLabel);
        if (this.objectValueSelected != null) {
            this.disableObject = true;
        }
        console.log('objectvalueselected', this.objectValueSelected);
       
        let objIndex = this.objectMdtList.findIndex(obj => obj.apiName == this.objectValueSelected);
        this.objMdtRec = this.objectMdtList[objIndex].value;

        //let objectMdtRec = this.objectMdtList[objIndex].value;
        if (this.objectMdtList[objIndex].filterVal != '') {
            this.filterCriteriaJsonString = this.objectMdtList[objIndex].filterVal;
        }
        console.log('json string', this.filterCriteriaJsonString);
        if(this.filterCriteriaJsonString!=''){
            this.isFilterFieldApplicale = true;
        }
        else{
            this.isFilterFieldApplicale = false;
            //this.showTypeOfFromUser = true;
            this.showToUserDropdown = true;
            this.isInternalUser = true;
            this.showFromUser = true;
        }

        let typeOfFromUserOpt = [];
        this.typeOfFromUserConst.forEach(opt => {
            typeOfFromUserOpt.push({ label: opt, value: opt });
        });
        this.fromUserOptions = typeOfFromUserOpt;

        getDynamicColumnHeaders({ app: this.appSelected, obj: this.objectValueSelected })
            .then((data) => {
                console.log('data at 423', data);
                this.columnHeaders = data;
                console.log('this.columnHeaders', this.columnHeaders);
            })
            .catch(error => {
                this.error = error;
            })

        if (this.filterCriteriaJsonString != null || this.filterCriteriaJsonString!='') {
            getFilterFieldWrapper({ filterCriteria: this.filterCriteriaJsonString })
                .then((data) => {
                    if (data != null) {
                        console.log('data at 402', data);
                        this.filterFieldList = data;
                        //let fltOptions = [];
                        let filterFieldData = [];
                        let filterFieldDt = [];
                        let filterFieldTxt = [];
                        for (const [key, value] of Object.entries(data)) {
                            if (key === 'picklist') {
                                let fltValues = value;                               
                                value.forEach(val => {
                                    let filterFieldObj = {};
                                    filterFieldObj.label = val.label;
                                    filterFieldObj.value = [];
                                    filterFieldObj.apiName = val.apiName;
                                    fltValues = val.values;
                                    fltValues.forEach(pickVal =>
                                        filterFieldObj.value.push({
                                            label: pickVal,
                                            value: pickVal
                                        })
                                    );
                                filterFieldData.push(filterFieldObj);

                                })
                                console.log('filterFieldData', filterFieldData);
                            }
                            else if(key === 'date'){
                                value.forEach(val => {
                                    let filterFieldObj = {};
                                    filterFieldObj.label = 'From '+val.label;
                                    filterFieldObj.apiName = val.apiName;
                                    filterFieldDt.push(filterFieldObj);
                                    filterFieldObj = {};
                                    filterFieldObj.label = 'To '+val.label;
                                    filterFieldObj.apiName = val.apiName;
                                    filterFieldDt.push(filterFieldObj);
                                })
                                console.log('filterFieldData', filterFieldDt);

                            }
                            else if(key === 'text'){
                                value.forEach(val => {
                                    let filterFieldObj = {};
                                    filterFieldObj.label = val.label;
                                    filterFieldObj.apiName = val.apiName;
                                    filterFieldTxt.push(filterFieldObj);

                                })
                                console.log('filterFieldData', filterFieldTxt);  

                            }

                        }
                        this.filterFieldDropdown = filterFieldData;
                        this.filterFieldDate = filterFieldDt;
                        this.filterFieldText = filterFieldTxt;
                        //this.filterFieldOptionsList = fltOptions;
                        console.log('filterFieldOptions', this.filterFieldList);
                       // console.log('fltOptions', this.filterFieldOptionsList);

                    }
                })
                .catch(error => {
                    console.log('error at 413', error);
                    this.error = error;
                });
        }
    }

    handlePicklistFilterFieldChange(event) {
        //console.log('at 420',event.detail.value);
        const apiName = event.target.dataset.id;
        const field = this.filterFieldDropdown.find(item => item.apiName === apiName);
        field.value = JSON.parse(JSON.stringify(event.detail.value));
        console.log('field', JSON.parse(JSON.stringify(field.value)));
        console.log('field', field);
        console.log('field.value',field.value);
        const existingFieldIndex = this.picklistFiltFldValueToApex.findIndex(item => item.apiName === apiName);

        if (existingFieldIndex !== -1) {
            // If the field exists, update its value
            this.picklistFiltFldValueToApex[existingFieldIndex].value = field.value;
        } else {
            // If the field doesn't exist, add it
            this.picklistFiltFldValueToApex.push({ apiName: apiName, value: field.value });
        }
        console.log('picklistFiltFldValueToApex',this.picklistFiltFldValueToApex);
        this.filterFieldsWrapper.picklistFiltFldWrapList = this.picklistFiltFldValueToApex;
        
        this.showTypeOfFromUser = true;
        this.typeOfFromUser = 'Internal User';
        this.fromUserTypeSelected = 'Internal User';
        this.isInternalUser = true;
        this.showFromUser = true;
    }
    handleFilterDate(event) {
        console.log('event in date',event);
        const label = event.target.dataset.id;
        const field = this.filterFieldDate.find(item => item.label === label);
        const apiName = field.apiName;
        console.log('apiName',apiName);
        console.log('selectedDate',this.selectedDate);
        console.log('field.label', field.label);
        field.value = event.target.value;
        console.log(' field.value', field.value);
        console.log('dateFiltFldValueToApex',this.dateFiltFldValueToApex);
        const existingFieldIndex = this.dateFiltFldValueToApex.findIndex(item => item.apiName === apiName);
        console.log('ind',existingFieldIndex);
        const context = field.label.includes("From")?'From':field.label.includes("To")?"To":'';
        console.log('context',context);

        if (existingFieldIndex !== -1) {
            // If the field exists, update its value
            if(context === "From"){
                this.dateFiltFldValueToApex[existingFieldIndex].startRange = field.value;
            }
            else if(context === "To"){
                this.dateFiltFldValueToApex[existingFieldIndex].endRange = field.value;
            }
        } else {
            // If the field doesn't exist, add it
            this.dateFiltFldValueToApex.push({ apiName: apiName, startRange: field.value,endRange: field.value });
        }
       
        console.log('dateFiltFldValueToApex',this.dateFiltFldValueToApex);
        this.filterFieldsWrapper.dtFiltFldWrapList = this.dateFiltFldValueToApex;

    }
    handleFilterText(event){
        console.log('event in text',event);
        const apiName = event.target.dataset.id;
        const field = this.filterFieldText.find(item => item.apiName === apiName);
        console.log('field', field);
        field.value = event.target.value;
        console.log('field.value', field.value);
        const existingFieldIndex = this.textFiltFldValueToApex.findIndex(item => item.apiName === apiName);

        if (existingFieldIndex !== -1) {
            // If the field exists, update its value
            this.textFiltFldValueToApex[existingFieldIndex].value = field.value;
        } else {
            // If the field doesn't exist, add it
            this.textFiltFldValueToApex.push({ apiName: apiName, value: field.value });
        }
        console.log('textFiltFldValueToApex',this.textFiltFldValueToApex);
        this.filterFieldsWrapper.txtFiltFldWrapList = this.textFiltFldValueToApex;
        
        
    }

    handleTypeofFromUserFilterChange(event) {
        this.typeOfFromUser = event.target.value;
        console.log('OUTPUT : typeofFromUser', this.typeofFromUser);
        if (this.typeOfFromUser === 'Internal User' || this.typeOfFromUser === 'System User' || this.selectProgram == 'CRM') {
            this.isInternalUser = true;
            this.isPartnerUser = false;
            this.showAccountOptions = false;
            this.showFromUser = true;
        }
        else if (this.typeOfFromUser === 'External User') {
            this.isInternalUser = false;
            this.showFromUser = true;
            this.isPartnerUser = true;
            this.showAccountOptions = true;
            this.showIntelAccount = true;
        }

        //fetch the account details only when he s a external user
        if (this.isPartnerUser) {
            console.log('in partner sce');
            getAccounts().then((data) => {
                let accountOpt = [];
                console.log('account data', data);
                for (const [key, value] of Object.entries(data)) {
                    accountOpt.push({ label: key, value: value });
                }
                this.accountOptions = accountOpt;
            })
                .catch(error => {
                    this.error = error;
                });
        }
        this.showToUser = false;
        this.disableGetData = true;
        this.fromUserName = '';
        this.valueselected = '';
        this.showTransactionDetails = false;
        this.showOwnershipUpdatedRecords = false;
    }

    handleAccountFilterChange(event) {
        this.accountValueSelected = event.detail;
        getNodeAccounts({ account: this.accountValueSelected, program: this.programValueSelected })
            .then((data) => {
                if (this.checkForUndefinedEmptyAndNull(data) && data !== {} && Object.keys(data).length > 0) {
                    let accountOpt = [];
                    console.log('Node accounts data', data);
                    for (const [key, value] of Object.entries(data)) {
                        accountOpt.push({ label: value, value: key });
                    }
                    this.nodeAccountOptions = accountOpt;
                    this.disbaleNodeAccount = false;
                } else {
                    const e = new ShowToastEvent({
                        title: 'Error',
                        message: 'No Node Accounts',
                        variant: 'error',
                        mode: 'dismissible'
                    });
                    this.dispatchEvent(e);
                }
            })
            .catch(error => {
                this.error = error;
            });
        // this.disableFromUser = false;
        // this.disableGetData = true;
        // this.valueselected = '';
        // this.nodeAccountValueSelected = '';
    }
    handleNodeAccountFilterChange(event) {
        this.nodeAccountValueSelected = event.target.value;
        this.showFromUser = true;
        console.log('node account Id', this.nodeAccountValueSelected);
    }

    handleTypeOfToUserFilterChange(event) {
        this.typeofToUser = event.target.value;
        console.log('type of to user', this.typeofToUser);
        this.showToUserDropdown = true;
        this.showUpdateOwnershipButton = false;
    }

    searchFromUser(event) {
        this.fromUserName = event.target.value;
        console.log('OUTPUT : fromUserName', event.target.value);
        //this.LoadingText = true;
        if (this.typeOfFromUser == 'Internal User' || this.typeOfFromUser == 'System User') {
            this.nodeAccountValueSelected = null;
        }
        if (this.fromUserName == '') {
            console.log('nulll');
            this.showTransactionDetails = false;
        }
        getUser({ userName: this.fromUserName, typeOfUser: this.typeOfFromUser, nodeAccountId: this.nodeAccountValueSelected, program: this.programValueSelected, app: this.appSelected,objConfigRec:this.objMdtRec })
            .then(result => {
                this.ownerName = result;
                console.log('result at 424', result);
                console.log(this.fromUserName);
                console.log('owner', this.ownerName);
                //this.LoadingText = false;
                this.dynamiClassname = result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open slds-size_3-of-12' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
                console.log('length' + result.length);
                if (result.length == 0) {
                    this.disableGetData = true;
                    this.messageFlag = true;
                    console.log('no record');
                }
                else {
                    this.messageFlag = false;
                    this.disableGetData = false;
                    console.log('record present');
                }
            })
            .catch(error => {
                console.log('-------error-------------' + error.body.message);
                console.log(error);
            });

    }
    getDataBasedOnSelAccntAndUser(event) {
        console.log('Inside 454');
        this.recId = event.currentTarget.dataset.id;
        var selectName = event.currentTarget.dataset.name;
        console.log('id=', this.recId);
        console.log('var', selectName);
        this.valueselected = selectName;
        console.log('value', this.valueselected);
        let newsObject = { 'recId': this.recId, 'recName': selectName };
        this.selectedIds.push(this.recId);
        this.ownerSelected.push(newsObject);
        this.dynamiClassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
        this.fromUserSelected = true;
    }

    getData() {
        console.log('this.filterFieldsWrapper in getdata'+JSON.stringify(this.filterFieldsWrapper));
        //this.filterFieldsWrapper = JSON.parse(JSON.stringify(this.filterFieldsWrapper));
        if(this.objectValueSelected == 'Dashboards'){
            getDashboardData({FromUser:this.valueselected})
            .then(response => {
                const data = response;
                console.log('response in Dashboard',data);
                this.recordsList = response;
                if (response) {
                    console.log('Dashboard data', data);
                    this.records = data;
                    console.log('records', this.records);
                    let result = [];
                    result = this.getformattedData(data);
        
                    console.log('result in wire', result);
                    this.objRecordsList = [...result];
                    console.log('objRecordsList in wire', this.objRecordsList);
                    this.objRecordsListcount = this.objRecordsList.length;
                    console.log('this.objRecordsListcount' + this.objRecordsListcount);
                    this.hasRecords = this.objRecordsListcount > 0 ? true : false;
                    this.showTransactionDetails = true;
                }
                else if (error) {
                    console.log('error', error);
                    this.error = error;
                }
            })
            .catch(error => {
                console.log('-------error-------------' + error);
                console.log(error);
                });

        }
        else{
        getObjectTransactions({ program: this.programValueSelected, objectname: this.objectValueSelected, accountId: this.nodeAccountValueSelected, user: this.valueselected, toUser:this.valueselectedNew, typeOfUser: this.typeOfFromUser, filtFldWrapper: this.filterFieldsWrapper, objConfigRec:this.objMdtRec,selectedIds: []}) 
            .then(response => {
        const data = response;
        //const error = response.error;
        this.recordsList = response;
        console.log('responce in wire', response);
        console.log('valueselected', this.valueselected);
        console.log('157 programValueSelected', this.programValueSelected);
        console.log('158 objectValueSelected', this.objectValueSelected);
        console.log('159 accId', this.nodeAccountValueSelected);
        console.log('160 typeOfFromUser', this.typeOfFromUser);
        console.log('object data', data);
        console.log('recordsList', this.recordsList);
        console.log('filterCriteria', this.filterCriteria);
        console.log('filterFieldsWrapper',this.filterFieldsWrapper);
        if (response) {
            console.log('campaign data', data);
            this.records = data;
            console.log('records', this.records);
            let result = [];
            result = this.getformattedData(data);

            console.log('result in wire', result);
            this.objRecordsList = [...result];
            console.log('objRecordsList in wire', this.objRecordsList);
            this.objRecordsListcount = this.objRecordsList.length;
            console.log('this.objRecordsListcount' + this.objRecordsListcount);
            this.hasRecords = this.objRecordsListcount > 0 ? true : false;
            this.showTransactionDetails = true;
        }
        else if (error) {
            console.log('error', error);
            this.error = error;
        }
   })
    .catch(error => {
    console.log('-------error-------------' + error);
    console.log(error);
    });
}
        if (this.fromUserSelected && this.isCRMPlatform) {
            //this.showCRMTransactions = true;
            this.showTransactionDetails = true;
        }
        else {
            if (this.objRecordsListcount == 0) {
                const e = new ShowToastEvent({
                    title: 'Error',
                    message: 'No Records Present',
                    variant: 'error',
                    mode: 'dismissible'
                });
                this.dispatchEvent(e);
            }
            else {
                console.log('has records');
                this.showTransactionDetails = true;
            }
        }

    }
    refreshToInitialSelection() {
        this.appSelected = 'Select Application/Platform';
        this.programSelected = 'Select Program';
        this.objectSelected = 'Select Object';
        this.disableProgram = false;
        this.disableObject = false;
        this.fromUserTypeSelected = 'Select Type Of From User';
        this.showTransactionDetails = false;
        this.valueselected = '';
        this.showToUser = false;
        this.showOwnershipUpdatedRecords = false;
        this.showCRMTransactions = false;
        this.filterCriteria = 'Select Filter Criteria';
        this.isProgramApplicable = false;
        this.isFilterFieldApplicale = false;
        this.showTypeOfFromUser = false;
        this.showFromUser = false;
        this.columnHeaders = [];
        this.isReportsOrDashboards = false;
        this.appSelected = '';
        this.objectValueSelected = '';
        this.isPartnerUser = false;
        this.filterCriteriaJsonString = '';

    }
    searchToUser(event) {
        this.toUserName = event.target.value;
        console.log('selected To User', this.toUserName);
        this.LoadingTextNew = true;
        console.log('in searching to user program', this.programValueSelected);
        console.log('in searching to user object', this.objectValueSelected);
        console.log('in searching to user user', this.toUserName);
        if (this.toUserName == '') {
            this.showUpdateOwnershipButton = false;
            this.showOwnershipUpdatedRecords = false;
        }
        getToUser({ program: this.programValueSelected, userName: this.toUserName, typeOfUser: this.typeofToUser, obj: this.objectValueSelected, App: this.appSelected, objConfigRec:this.objMdtRec })
            .then(result => {
                console.log('result', result);
                this.toUserList = result;
                this.LoadingTextNew = false;
                this.dynamiClassnamenew = result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open slds-size_3-of-12' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
                console.log('length' + result.length);
                if (result.length == 0) {
                    this.disableUpdateOwnershipButton = true;
                    this.messageFlagNew = true;
                    console.log('no record');
                }
                else {
                    this.messageFlagNew = false;
                    this.disableUpdateOwnershipButton = false;
                    console.log('record present');
                }
            })
            .catch(error => {
                console.log('-------error-------------' + error);
                console.log(error);
            });

    }
    setSelectedRecordNew(event) {
        this.ownerSelectedNew = [];
        this.recIdNew = event.currentTarget.dataset.id;
        var selectNameNew = event.currentTarget.dataset.name;
        console.log('to user', this.recIdNew);
        console.log(selectNameNew);
        this.valueselectedNew = selectNameNew;
        console.log('valueselectedNew',this.valueselectedNew);
        let newsObjectNew = { 'recId': this.recIdNew, 'recName': selectNameNew };
        this.selectedIdsNew.push(this.recIdNew);
        console.log('selectedids', this.selectedIdsNew);
        this.ownerSelectedNew.push(newsObjectNew);
        this.dynamiClassnamenew = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
        if (this.ownerSelectedNew != [] && this.ownerSelectedNew.length > 0) {
            this.showUpdateOwnershipButton = true;
        }

    }
    handleRowSelected(event) {
        const selectedRows = event.detail.selectedRows;
        console.log('rows', selectedRows);
        for (let i = 0; i < selectedRows.length; i++) {
            console.log("You selected: " + selectedRows[i].Id);
            this.selectedRowIds.push(selectedRows[i].Id);
        }
        let typeOfTOUserOpt = [];
        this.typeOfToUserConst.forEach(opt => {
            typeOfTOUserOpt.push({ label: opt, value: opt });
        });
        this.toUserOptions = typeOfTOUserOpt;
        //if(this.appSelected == 'CCP'){
        this.showToUser = true;
        //}  
        if (this.appSelected == 'CRM') {
            this.showToUserDropdown = true;
        }
        if (selectedRows.length > 20) {
            const e = new ShowToastEvent({
                title: 'Warning',
                message: 'Please select upto 20 records per each transaction',
                variant: 'Warning',
                mode: 'dismissible'
            });
            this.dispatchEvent(e);
        }
    }

    updateOwnerOnSelectedRecords() {
        this.showSpinner = true;
        this.selectedRowIds = Array.from(new Set(this.selectedRowIds));
        console.log('selectedRowIds', this.selectedRowIds);
        console.log('toUser', this.recIdNew);
        updateOwner({ selectedRowIds: this.selectedRowIds, toUser: this.recIdNew, obj: this.objectValueSelected, objConfigRec:this.objMdtRec})
            .then(result => {
                console.log('res at 617', JSON.stringify(result));
                let bool = result.res;
                let updatedRecordList = result.updatedRecordsList;
                console.log('bool at 620', bool);
                console.log('this.selectedRowIds length', this.selectedRowIds.length);
                if (bool == true) {
                    this.selectedRowIds.forEach(selRow => {
                        let selRowIndex = this.objRecordsList.findIndex(objRec => objRec.Id === selRow);
                        console.log('selRowIndex', selRowIndex);
                        if (this.checkForUndefinedEmptyAndNull(selRowIndex) && selRowIndex !== -1) {
                            let updatedRec = this.objRecordsList[selRowIndex];
                            this.updatedRecordList.push(this.objRecordsList[selRowIndex]);
                        }
                    });
                    this.updatedRecordList = this.getformattedData(updatedRecordList);
                    this.showOwnershipUpdatedRecords = (this.updatedRecordList !== [] && this.updatedRecordList.length > 0) ? true : false;
                    console.log('updatedRecordList', this.updatedRecordList);
                    refreshApex(this.recordsList);
                    if (this.selectedRowIds.length > 20) {
                        const evt1 = new ShowToastEvent({
                            title: 'Info',
                            message: 'Owner Update for the selected records are in Progress. Once the owner transfer is completed, you will be notified via email',
                            variant: 'info',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt1);
                    }
                    else if (this.fromUserName == this.toUserName) {
                        const evt = new ShowToastEvent({
                            variant: 'error',
                            title: '',
                            message: 'Existing user and New user cannot be same'
                        });
                        this.dispatchEvent(evt);
                        this.error = true;
                    }
                    else {
                        this.updatedRecordList = this.getformattedData(updatedRecordList);
                        console.log('line 503 updatedRecordList', this.updatedRecordList);
                        this.showOwnershipUpdatedRecords = (this.updatedRecordList !== [] && this.updatedRecordList.length > 0) ? true : false;
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: 'Owner Updated successfully',
                            variant: 'success',
                            mode: 'dismissible'
                        });
                        this.dispatchEvent(evt);
                    }
                    this.showSpinner = false;
                }
            }).catch(error => {
                this.showSpinner = false;
                console.log('-------error-------------' + error);
                console.log(error);
            });
        refreshApex(this.objRecordsList);

    }

    checkForUndefinedEmptyAndNull(input) {
        let isNotUndefinedEmptyAndNull = false;
        if (input !== undefined && input !== null && input !== "") {
            isNotUndefinedEmptyAndNull = true;
        } else {
            isNotUndefinedEmptyAndNull = false;
        }
        return isNotUndefinedEmptyAndNull;
    }
    getformattedData(data, objName) {
        let result = [];
        data.forEach(currentItem => {
            if (this.objectValueSelected == 'PartnerFundClaim' || this.objectValueSelected == 'PartnerFundRequest') {
                result = [...result, { Id: currentItem.Id, Name: currentItem.Title, ChannelProgram: currentItem.Core_MDF_Program__c, OwnerName: currentItem.Owner.Name, AccountName: currentItem.ChannelPartner.Name, AccountId: currentItem.ChannelPartnerId, EmailId: currentItem.Owner.Email }];
            }
            else if (this.objectValueSelected == 'Account') {
                result = [...result, { Id: currentItem.Id, Name: currentItem.Name, ChannelProgram: currentItem.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, OwnerName: currentItem.Owner.Name, AccountName: currentItem.Name, AccountId: currentItem.Id, EmailId: currentItem.Owner.Email }];
            }
            else if (this.objectValueSelected == 'Lead') {
                result = [...result, { Id: currentItem.Id, Name: currentItem.Name, Company: currentItem.Company, LeadStatus: currentItem.Core_Lead_Status__c, CreatedDate: currentItem.CreatedDate, Email: currentItem.Email }];
            }
            else if (this.objectValueSelected == 'Opportunity') {
                result = [...result, { Id: currentItem.Id, OpportunityName: currentItem.Name, AccountName: currentItem.AccountId, Stage: currentItem.StageName, OpportunityOwner: currentItem.Core_Opportunity_Owner__c, TechnicalOwner: currentItem.Core_Technical_Owner__c, DecisionDate: currentItem.CloseDate, CreatedDate: currentItem.CreatedDate, LastModifiedDate: currentItem.LastModifiedDate, OpportunityID: currentItem.Core_Opportunity_ID__c }];
            }
            else if (this.objectValueSelected == 'Reports') {
                result = [...result, { ReportId: currentItem.Id,Name: currentItem.Name, FolderName: currentItem.FolderName, LastRunDate: currentItem.LastRunDate}];
            }
            else if (this.objectValueSelected == 'Dashboards') {
                result = [...result, { DashaboardName: currentItem.DashaboardName, RunningUsrName: currentItem.RunningUsrName, RunningUsrisActive: currentItem.RunningUsrisActive,ReportName:currentItem.ReportName}];
            }
            else {
                result = [...result, { Id: currentItem.Id, Name: currentItem.Name, ChannelProgram: currentItem.Core_MDF_Program__c, OwnerName: currentItem.Owner.Name, AccountName: currentItem.Core_MDF_Account__r.Name, AccountId: currentItem.Core_MDF_Account__c, EmailId: currentItem.Owner.Email }];
            }
        });
        return result;

    }
    handleAccordionToggle(event) {
        const secName = event.detail.name;
        const openSections = event.detail.openSections;
        this.valueselected = this.fromUserName;
        openSections.forEach(sectionName => {
            this.objectValueSelected = sectionName;
            console.log('this.objectValueSelected' + this.objectValueSelected);
            // Fetch data for each open section dynamically
            this.fetchObjectRecords(sectionName);
        });

    }
    fetchObjectRecords(objectId) {
        getObjectTransactions({ program: '', objectname: objectId, accountId: '', user: this.valueselected, toUser:this.valueselectedNew,typeOfUser: '', selectedIds: [] })
            .then(result => {
                console.log('result', result);
                let res = [];
                res = this.getformattedData(result);
                this.crmObjectData = res;
                console.log('this.crmObjectData', this.crmObjectData);
                this.crmObjectData = result;
                this.objRecordsListcount = this.crmObjectData.length > 0 ? true : false;
                this.sectionData = { ...this.sectionData, [objectId]: res };
                let objInd = this.objectOptions.findIndex(obj => obj.value == objectId);
                this.objectOptions[objInd].records = res;
                console.log('object options', this.objectOptions);
                this.crmObjectData = [];
            })
            .catch(error => {
                console.error('Error fetching object records:', error);
            });
    }

    handleTestFilterDate(event) {
        this.selectedSampleDate = event.target.value;
        let selecDtWrapper = {'startRange': this.selectedSampleDate};
        console.log('selectedSampleDate',this.selectedSampleDate);
        testDateChange({
            dateWrapper: selecDtWrapper
        }).then (res => {
            console.log('res', res);
        }).catch(ex => {
            console.log('ex',ex);
        })
    }
    
}