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
import getDynamicColumnHeaders from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getDynamicColumnHeaders';
//custom labels
import programLabel from '@salesforce/label/c.Core_MDF_Program';
import accountLabel from '@salesforce/label/c.Core_MDF_Channel_Partner';
import nodeaccountLabel from '@salesforce/label/c.Core_MDF_Account_Node';
import selectProgram from '@salesforce/label/c.Core_MDF_LWC_SelectProgram_Label';
import selectAccount from '@salesforce/label/c.Core_MDF_LWC_SelectAccount_Label';
import getDataLabel from '@salesforce/label/c.Core_MDF_GetData';
//import filterCriteriaLabel from '@salesforce/label/c.Core_MDF_Filter_Criteria_Label'
//import resetToDefault from '@salesforce/label/c.Core_MDF_ResetToDefault';



export default class Core_MDF_Mass_Owner_Update_New extends LightningElement {
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
    @track objRecordsListcount = '';
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
    @track crmSelObj ='';
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
    programOptionsList=[];
    objectOptionsList=[];
    @track filterFieldList=[];
    filterFieldOptionsList =[];
    crmObjectData=[];
    filterFieldApplicable = false;
    @track filterCriteria = [];
    @track filterCriteriaLabel = '';
    columnHeaders = [];
    @track columns = [{
        label: 'Id',
        fieldName: 'Id',
        type: 'Id',
        sortable: true,
        disabled: true,
    },
    {
        label: 'Name',
        fieldName: 'Name',
        type: 'text',
        sortable: true,
        disabled: false,
    },
    {
        label: 'Channel Program',
        fieldName: 'Core_MDF_Program__c',
        type: 'text',
        sortable: true,
        disabled: false,
    },
    {
        label: 'Owner Name',
        fieldName: 'ownerName',
        type: 'text',
        sortable: true,
        disabled: false,
    },
    {
        label: 'Account Name',
        fieldName: 'accountName',
        type: 'text',
        sortable: true,
        disabled: false,
    },
    {
        label: 'AccountId',
        fieldName: 'accountId',
        type: 'text',
        sortable: true,
        disabled: false,
    },
    {
        label: 'EmailId',
        fieldName: 'ownerEmail',
        type: 'text',
        sortable: true,
        disabled: false,
    }
    ];
    @track CRMcolumns = [{
        label: 'Id',
        fieldName: 'Id',
        type: 'Id',
        sortable: true,
        disabled: true,
    },
    {
        label: 'Name',
        fieldName: 'Name',
        type: 'text',
        sortable: true,
        disabled: false,
    },
    {
        label: 'Owner Name',
        fieldName: 'ownerName',
        type: 'text',
        sortable: true,
        disabled: false,
    },

    {
        label: 'EmailId',
        fieldName: 'ownerEmail',
        type: 'text',
        sortable: true,
        disabled: false,
    }
    ];
    @track sectionData = {};
    @track showCRMTransactions = false;
    @track isFilterFieldApplicale = false;
    @track filterCriteriaJsonString = '';
    @wire(getObjectTransactions, { program: '$programValueSelected', objectname: '$objectValueSelected', accountId: '$nodeAccountValueSelected', user: '$valueselected', typeOfUser: '$typeOfFromUser', filterCriteria : '$filterCriteria', startDate : '$startDateSelected', endDate : '$endDateSelected', selectedIds:[]})
    wiredCampaigns(response) {
        const data = response.data;
        const error = response.error;
        this.recordsList = response;
        console.log('responce in wire',response);
        console.log('valueselected', this.valueselected);
        console.log('157 programValueSelected',this.programValueSelected);
        console.log('158 objectValueSelected',this.objectValueSelected);
        console.log('159 accId',this.nodeAccountValueSelected);
        console.log('160 typeOfFromUser',this.typeOfFromUser);
        console.log('object data',data);
        console.log('recordsList', this.recordsList);
        console.log('filterCriteria', this.filterCriteria);
        if (data) {
            console.log('campaign data', data);
            this.records = data;
            console.log('records', this.records);
            let result = [];
            result = this.getformattedData(data);
            /*data.forEach(currentItem => {
                if (this.objectValueSelected == 'PartnerFundClaim' || this.objectValueSelected == 'PartnerFundRequest') {
                    result = [...result, { Id: currentItem.Id, Name: currentItem.Title, Core_MDF_Program__c: currentItem.Core_MDF_Program__c, ownerName: currentItem.Owner.Name, accountName: currentItem.ChannelPartner.Name, accountId: currentItem.ChannelPartnerId, ownerEmail: currentItem.Owner.Email }];
                }
                else if(this.objectValueSelected == 'Account') {
                    result = [...result, { Id:currentItem.Id, Name: currentItem.Name, Core_MDF_Program__c: currentItem.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, ownerName: currentItem.Owner.Name, accountName: currentItem.Name, accountId: currentItem.Id, ownerEmail: currentItem.Owner.Email}];
                }
                else {
                    result = [...result, { Id: currentItem.Id, Name: currentItem.Name, Core_MDF_Program__c: currentItem.Core_MDF_Program__c, ownerName: currentItem.Owner.Name, accountName: currentItem.Core_MDF_Account__r.Name, accountId: currentItem.Core_MDF_Account__c, ownerEmail: currentItem.Owner.Email }];
                }
            });*/
            console.log('result in wire',result);
            this.objRecordsList = [...result];
            console.log('objRecordsList in wire', this.objRecordsList);
            this.objRecordsListcount = this.objRecordsList.length;
            console.log('this.objRecordsListcount'+this.objRecordsListcount);
            this.hasRecords = this.objRecordsListcount>0?true:false;
        }
        else if (error) {
            console.log('error', error);
            this.error = error;
        }
    }
    connectedCallback() {
        this.getApp();
        /*this.childComponent = this.template.querySelector('c-core_-m-d-f_-multi-select-picklist');
        
        if (this.childComponent) {
            // Add event listener when connected
            this.childComponent.addEventListener('filterselection', this.handleFilterFieldChange);
        }*/
    }
    getApp() {
        getAppData()
            .then((data) => {
                console.log('data', data);
                if (this.checkForUndefinedEmptyAndNull(data) && data !== {}) {
                    this.massOwnerMdtList = data.mdtList;
                    console.log('massOwnerMdtList',this.massOwnerMdtList);
                    this.appOptions = data.applicationList;
                    console.log('210 this.appOptions',this.appOptions);
                    this.programOptionsList = data.programList;
                    console.log('programOptionsList',this.programOptionsList);
                    this.objectOptionsList = data.objectList;
                    console.log('objectOptions',this.objectOptionsList);
                    console.log('app options', this.appOptions);
                    this.filterFieldList = data.filterFieldList;
                    console.log('filterFielfOptions', this.filterFieldList);
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
                type: 'text' ,
                sortable: true,
                disabled: false,         
            };
        });
    }
    

    handleAppFilterChange(event) {
        this.showFromUser = false;
        let selectedPlatform = event.target.value;
        console.log('app selected',selectedPlatform);
        if(selectedPlatform == 'CRM'){
            this.isCRMPlatform = true;
            this.nodeAccountValueSelected = null;
            //this.isFilterFieldApplicale = true;
        }
        else{
            this.isCRMPlatform = false;
            this.disableProgram = false;
            this.disableObject = false;
            this.filterFieldApplicable = false;
            this.isFilterFieldApplicale = false;
        }
       // let programOptionsList = [];
        let mdtIndex = this.massOwnerMdtList.findIndex(mdt => mdt.Core_MDF_App__c === selectedPlatform);
        let isProgramApplicable = this.massOwnerMdtList[mdtIndex].Core_MDF_isProgramApplicable__c;
        let massOwnerMdtList = this.massOwnerMdtList;
        if (isProgramApplicable) {
            /*massOwnerMdtList.forEach(mdt => {
                if (mdt.Core_MDF_App__c === selectedPlatform) {
                    //programOptionsList.push({ label: mdt.Core_MDF_Program__c, value: mdt.Core_MDF_Program__c });
                    this.programOptions = this.programOptionsList;
                }
            });*/
            this.programOptions = this.programOptionsList;
            console.log('programOptions', this.programOptions);
        }
        this.isProgramApplicable = isProgramApplicable;
        this.appSelected = selectedPlatform;
        let objectOptions = [];
        if(this.appSelected == 'CRM'){
            massOwnerMdtList.forEach(mdt => {
                    if (mdt.Core_MDF_App__c === this.appSelected) {
                        objectOptions.push({ label: mdt.Core_MDF_Object_Label__c, value: mdt.Core_MDF_Object__c, records: []});
                    }  
                
            });
            this.objectOptions = objectOptions;
            this.objectOptions.sort((a, b) => a.label.localeCompare(b.label));
                    this.objectOptions=this.objectOptions.sort();
            //this.showTypeOfFromUser = true;
            this.filterFieldApplicable = true;
        }
        else{
            this.objectOptions = []
            //this.showTypeOfFromUser = false;
            this.filterFieldApplicable = false;
        }
        console.log('object options at line 261',this.objectOptions);
        console.log('filterField',this.filterFieldApplicable);
         if( this.appSelected != null){
            this.disableApp = true;
        }
    }

    handleProgramFilterChange(event) {
        this.programValueSelected = event.target.value;
        this.showTypeOfFromUser = true;
        if(this.programValueSelected != null){
            this.disableProgram = true;
        }
        //let previousSelectedProgram = '';        
        console.log('242 program selected',this.programValueSelected);
        /*let programselected = new List();
        programselected.add(this.programValueSelected);
        programselected.forEach(program => {
            if(program === this.programValueSelected){
                reset = true;
            }
        })*/
       /* if(this.previousSelectedProgram !=  this.programValueSelected){
            console.log('244 true');
            this.reset = true;
        }*/
       let massOwnerMdtList = this.massOwnerMdtList;
       console.log('line 240',massOwnerMdtList);
        let objectOptions = [];
        massOwnerMdtList.forEach(mdt => {
                if (mdt.Core_MDF_App__c === this.appSelected && mdt.Core_MDF_Program__c === this.programValueSelected) {
                    objectOptions.push({ label: mdt.Core_MDF_Object_Label__c, value: mdt.Core_MDF_Object__c});
                }  
            
        });
        //this.previousSelectedProgram = this.programValueSelected;
        console.log('objectOptions',objectOptions);
            this.objectOptions = objectOptions;
            this.objectOptions.sort((a, b) => a.label.localeCompare(b.label));
            this.objectOptions=this.objectOptions.sort();
            
    }

    handleobjectFilterChange(event) {
        console.log('object selected',event);
        this.objectValueSelected = event.target.value;
        console.log('at 393',event.target.value);
       /* if(this.appSelected == 'CRM'){
            this.isFilterFieldApplicale = true;
        }
        else{
            this.isFilterFieldApplicale = false;
        }*/
        let objInd = this.objectOptions.findIndex(obj => obj.value == this.objectValueSelected);
        this.selectedObjectLabel = this.objectOptions[objInd].label;
        console.log('selectedObjectLabel',this.selectedObjectLabel);
        if(this.objectValueSelected != null){
            this.disableObject = true;
        }
        //this.objectValueSelected = this.objectOptions.get(this.objectValueSelectedUI);
        console.log('objectvalueselected',this.objectValueSelected);
       // this.filterCriteriaLabel = this.objectValueSelected == 'Lead'?'Lead Status':(this.objectValueSelected == 'Opportunity')?'Stage':'Filter Criteria';
       if(this.objectValueSelected != 'Reports' || this.objectValueSelected != 'Dashboards'){
       if (this.massOwnerMdtList != null){
       this.massOwnerMdtList.forEach(mdt => {
        if (mdt.Core_MDF_App__c === this.appSelected && mdt.Core_MDF_Object__c === this.objectValueSelected && mdt.Core_MDF_Filter_Criteria__c != null) {
            this.filterCriteriaJsonString = mdt.Core_MDF_Filter_Criteria__c;
        }  
    
        });
				 if(this.filterCriteriaJsonString!=null){
            this.isFilterFieldApplicale = true;
        }
        else{
            this.isFilterFieldApplicale = false;
        }
        const obj = JSON.parse(this.filterCriteriaJsonString);
       this.filterCriteriaLabel = 'Filter by: '+obj.Label;
       console.log('Filter Criteria Label',this.filterCriteriaLabel);
       }

        let typeOfFromUserOpt = [];
        this.typeOfFromUserConst.forEach(opt => {
            typeOfFromUserOpt.push({ label: opt, value: opt });
        });
        this.fromUserOptions = typeOfFromUserOpt;
        //this.showTypeOfFromUser = true;
        console.log('programselected',this.programSelected);
        console.log('app Selected',this.appSelected);
        console.log('objselected',this.objectValueSelected);
        getDynamicColumnHeaders({app: this.appSelected, obj:this.objectValueSelected})
            .then((data) =>{
                console.log('data at 423',data);
                this.columnHeaders = data;
                console.log('this.columnHeaders',this.columnHeaders);
            })
            .catch(error=>{
                this.error = error;
            });
       if(this.filterCriteriaJsonString!=undefined && this.objectValueSelected != 'Reports' && this.objectValueSelected != 'Dashboards'){
        getFilterFieldList({ program: this.programSelected, app: this.appSelected, obj: this.objectValueSelected})
        .then((data) => {
            if(data!=null){
            console.log('data at 402',data);
            this.filterFieldList = data;
            let fltOptions = [];
            this.filterFieldList.forEach(fltopt => {
                fltOptions.push({label: fltopt, value: fltopt});
            })
            this.filterFieldOptionsList = fltOptions;
            console.log('filterFieldOptions', this.filterFieldList);
            console.log('fltOptions',this.filterFieldOptionsList);
        
        }
        })
        .catch(error => {
            console.log('error at 413',error);
            this.error = error;
        });
    }}
    } 
    handleFilterFieldChange(event){
        //console.log('at 420',event.detail.value);
        this.filterCriteria = event.detail.value;
        console.log('this.filterCriteria',this.filterCriteria);
        //console.log('at 422',event);
        //this.filterCriteria = event.detail;
        //console.log('event.detail',event.detail);
       // console.log(' this.filterCriteria', JSON.parse(JSON.stringify(event.detail.valueObj)));
        this.showTypeOfFromUser = true;
        this.typeOfFromUser = 'Internal User';
        this.fromUserTypeSelected = 'Internal User';
        this.isInternalUser = true;
        this.showFromUser = true;
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
        console.log('type of to user',this.typeofToUser);
        this.showToUserDropdown = true;
        this.showUpdateOwnershipButton = false;
    }

    searchFromUser(event) {
        this.fromUserName = event.target.value;
        console.log('OUTPUT : fromUserName', event.target.value);
        //this.LoadingText = true;
        if (this.typeOfFromUser == 'Internal User' || this.typeOfFromUser == 'System User' ) {
            this.nodeAccountValueSelected = null;
        }
        if(this.fromUserName == ''){
            console.log('nulll');
            this.showTransactionDetails = false;
        }
        getUser({ userName: this.fromUserName, typeOfUser: this.typeOfFromUser, nodeAccountId: this.nodeAccountValueSelected, program: this.programValueSelected, app: this.appSelected })
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
        if(this.fromUserSelected && this.isCRMPlatform){
            //this.showCRMTransactions = true;
            this.showTransactionDetails = true;
        }
        else{
            if (this.records.length == 0){
                const e = new ShowToastEvent({
                    title: 'Error',
                    message: 'No Records Present',
                    variant: 'error',
                    mode: 'dismissible'
                });
                this.dispatchEvent(e);
            }
            else {
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


    }
    searchToUser(event) {
        this.toUserName = event.target.value;
        console.log('selected To User', this.toUserName);
        this.LoadingTextNew = true;
        console.log('in searching to user program', this.programValueSelected);
        console.log('in searching to user object', this.objectValueSelected);
        console.log('in searching to user user', this.toUserName);
        if(this.toUserName == ''){
            this.showUpdateOwnershipButton = false;
            this.showOwnershipUpdatedRecords = false;
        }
        getToUser({ program: this.programValueSelected, userName: this.toUserName, typeOfUser: this.typeofToUser, obj: this.objectValueSelected,App: this.appSelected })
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
        let newsObjectNew = { 'recId': this.recIdNew, 'recName': selectNameNew};
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
        if(this.appSelected == 'CRM'){
            this.showToUserDropdown = true;
        } 
            if (selectedRows.length > 20){
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
        console.log('selectedRowIds',this.selectedRowIds);
        console.log('toUser',this.recIdNew);
        updateOwner({ selectedRowIds: this.selectedRowIds, toUser: this.recIdNew, fromUser: null, obj: this.objectValueSelected })
            .then(result => {
                console.log('res at 617',JSON.stringify(result));
                let bool = result.res;
                let updatedRecordList = result.updatedRecordsList;
                console.log('bool at 620',bool);
                console.log('this.selectedRowIds length',this.selectedRowIds.length);
                if (bool == true) {
                    this.selectedRowIds.forEach(selRow => {
                        let selRowIndex = this.objRecordsList.findIndex(objRec => objRec.Id === selRow);
                        console.log('selRowIndex',selRowIndex);
                        if(this.checkForUndefinedEmptyAndNull(selRowIndex) && selRowIndex !== -1) {
                           let updatedRec = this.objRecordsList[selRowIndex];
                            this.updatedRecordList.push(this.objRecordsList[selRowIndex]);
                        }
                    });
                    this.updatedRecordList = this.getformattedData(updatedRecordList);
                    this.showOwnershipUpdatedRecords = (this.updatedRecordList !== [] && this.updatedRecordList.length > 0) ? true : false;
                    console.log('updatedRecordList',this.updatedRecordList);
                    refreshApex(this.recordsList);
                    if(this.selectedRowIds.length > 20){
                        const evt1 = new ShowToastEvent({
                        title: 'Info',
                        message: 'Owner Update for the selected records are in Progress. Once the owner transfer is completed, you will be notified via email',
                        variant: 'info',
                        mode: 'dismissable'
                        });
                        this.dispatchEvent(evt1);
                    }
                    else if(this.fromUserName==this.toUserName){
                        const evt = new ShowToastEvent({
                            variant:'error',
                            title:'',
                            message: 'Existing user and New user cannot be same'
                        });
                        this.dispatchEvent(evt);
                        this.error=true;
                    }
                    else{
                        this.updatedRecordList = this.getformattedData(updatedRecordList);
                        console.log('line 503 updatedRecordList',this.updatedRecordList);
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
    getformattedData(data,objName){
        let result = [];
        data.forEach(currentItem => {
            if (this.objectValueSelected == 'PartnerFundClaim' || this.objectValueSelected == 'PartnerFundRequest') {
                result = [...result, { Id: currentItem.Id, Name: currentItem.Title, ChannelProgram: currentItem.Core_MDF_Program__c, OwnerName: currentItem.Owner.Name, AccountName: currentItem.ChannelPartner.Name, AccountId: currentItem.ChannelPartnerId, EmailId: currentItem.Owner.Email }];
            }
            else if(this.objectValueSelected == 'Account') {
                result = [...result, { Id:currentItem.Id, Name: currentItem.Name, ChannelProgram: currentItem.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, OwnerName: currentItem.Owner.Name, AccountName: currentItem.Name, AccountId: currentItem.Id, EmailId: currentItem.Owner.Email}];
            }
            else if(this.objectValueSelected == 'Lead'){
                result = [...result, { Id: currentItem.Id, Name: currentItem.Name, Company: currentItem.Company, LeadStatus: currentItem.Core_Lead_Status__c, CreatedDate:  currentItem.CreatedDate, Email: currentItem.Email }];
            }
            else if(this.objectValueSelected == 'Opportunity'){
                result = [...result, { Id: currentItem.Id, OpportunityName:currentItem.Name, AccountName: currentItem.AccountId, Stage: currentItem.StageName, OpportunityOwner: currentItem.Core_Opportunity_Owner__c, TechnicalOwner:  currentItem.Core_Technical_Owner__c, DecisionDate: currentItem.CloseDate, CreatedDate:currentItem.CreatedDate, LastModifiedDate: currentItem.LastModifiedDate, OpportunityID: currentItem.Core_Opportunity_ID__c}];
            }
            else {
                result = [...result, { Id: currentItem.Id, Name: currentItem.Name, ChannelProgram: currentItem.Core_MDF_Program__c, OwnerName: currentItem.Owner.Name, AccountName: currentItem.Core_MDF_Account__r.Name, AccountId: currentItem.Core_MDF_Account__c, EmailId: currentItem.Owner.Email }];
            }
        });
        return result;

    }
    handleAccordionToggle(event){
        const secName = event.detail.name;
        const openSections = event.detail.openSections;
        this.valueselected = this.fromUserName;
        openSections.forEach(sectionName => {
            this.objectValueSelected = sectionName;
            console.log('this.objectValueSelected'+this.objectValueSelected);
            // Fetch data for each open section dynamically
            this.fetchObjectRecords(sectionName);
        });
        /*console.log('secName',secName);
        const objectId = event.detail.openSections[0]; // Get the Id of the opened section
        console.log('event.detail.openSections',event.detail.openSections);
        this.crmSelObj = objectId;
        this.objectValueSelected = objectId;
        this.valueselected = this.fromUserName;
        console.log('this.valueselected',this.valueselected);
        console.log('objectId',objectId);
        if (objectId) {
            this.fetchObjectRecords(objectId);
        }*/

    }
    fetchObjectRecords(objectId) {
        getObjectTransactions({ program: '', objectname: objectId, accountId: '', user: this.valueselected, typeOfUser: '', selectedIds:[]})
            .then(result => {
                console.log('result',result);
                let res = [];
                res = this.getformattedData(result);
                this.crmObjectData = res;
                console.log('this.crmObjectData',this.crmObjectData);
                this.crmObjectData = result;
                this.objRecordsListcount = this.crmObjectData.length>0?true:false;
                this.sectionData = { ...this.sectionData, [objectId]: res };
                let objInd = this.objectOptions.findIndex(obj => obj.value == objectId);
                this.objectOptions[objInd].records = res;
                console.log('object options',this.objectOptions);
                this.crmObjectData = [];
            })
            .catch(error => {
                console.error('Error fetching object records:', error);
            });
    }
    handleStartDate(event){
        var selectedDate = event.target.value;
        const dateTimeString = selectedDate + 'T12:00:00Z'; // Result: "2024-06-01T12:00:00Z"

        // Convert the string to a JavaScript Date object
        //this.selectedDateTime = new Date(dateTimeString);
        this.startDateSelected = new Date(selectedDate);
        console.log(' this.startDateSelected', this.startDateSelected);

    }
    handleendDate(event){
        var selectedEndDate = event.target.value;
        const dateEndTimeString = selectedEndDate + 'T12:00:00Z';
        this.endDateSelected = new Date(selectedEndDate);
        console.log(' this.endDateSelected', this.endDateSelected);

    }

}