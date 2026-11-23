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

import getFilterFieldWrapper from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getFilterFieldWrapper';

import getDashboardData from '@salesforce/apex/CRM_Create_Dashbord_detail.Create_Dasboard_Data';
import shareReportFolder from '@salesforce/apex/CRM_UpdateReportsAndDashbords.shareReportFolder';

//custom labels
import programLabel from '@salesforce/label/c.Core_MDF_Program';
import accountLabel from '@salesforce/label/c.Core_MDF_Channel_Partner';
import nodeaccountLabel from '@salesforce/label/c.Core_MDF_Account_Node';
import selectProgram from '@salesforce/label/c.Core_MDF_LWC_SelectProgram_Label';
import selectAccount from '@salesforce/label/c.Core_MDF_LWC_SelectAccount_Label';
import getDataLabel from '@salesforce/label/c.Core_MDF_GetData';
import applicationErrorMsg from "@salesforce/label/c.Core_MDF_ApplicationErrorMessage";
//import testDateChange from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.testDateChange'
//import resetToDefault from '@salesforce/label/c.Core_MDF_ResetToDefault';



export default class Core_Mass_Access_Ownership_Transfer extends LightningElement {
    massOwnerMdtList;
    appWithProgramList;
    isProgramApplicable = false;
    showTypeOfFromUser = false;
    showIntelAccount = false;
    disbaleNodeAccount = true;
    disbaleToNodeAccount = true;
    disableProgram = false;
    disableObject = false;
    disableApp = false;
    showGetData = false;
    @track accountValueSelected = null;
    @track nodeAccountValueSelected = null;
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
    objRecordsListcount = 0;
    @track hasRecords;
    @track appSelected = '';
    @track messageFlagNew = false;
    @track messageFlagForAcc = false;
    @track toUserList = [];
    @track ownerSelectedNew = [];
    @track recIdNew;
    @track ownerName = [];
    @track intelAccounts = [];
    @track messageFlag = false;
    typeOfFromUserConst = ['External User', 'Internal User', 'System User'];
    typeOfToUserConst = ['External User', 'Internal User'];
    accountQueryFilter = 'Core_Account_Record_Type__c=\'Intel Account\' and Core_MDF_CoMarketingActive__c=true WITH SECURITY_ENFORCED order by Name asc';
    @track dynamiClassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
    @track dynamiClassnamenew = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
    @track dynamicClassForToUser = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
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
    @track selectedRowIds = [];
    newselectedRowIds = [];
    @track fromUserOptions = [];
    @track toUserOptions = []
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
    @track objectSelected = '';
    nodeAccountSelected = '';
    typeOfFromUser = '';
    typeofToUser = '';
    fromUserName = '';
    toUserName = '';
    isInternalUser = false;
    isPartnerUser = false;
    @track isPartnerToUser = false;
    @track disableGetData = true;
    disableAccountOptions = false;
    showToUserDropdown = false;
    disableToUserDropdown = false;
    recordsList;
    updatedRecordList = [];
    showOwnershipUpdatedRecords = false;
    typeOfFromUserConst = ['External User', 'Internal User', 'System User'];
    typeOfToUserConst = ['External User', 'Internal User'];
    showSpinner = false;
    objectOptionsList = [];
    @track filterFieldList = [];
    //filterFieldOptionsList = [];
    crmObjectData = [];
    @track filterCriteria = [];
    @track filterCriteriaLabel = '';
    @track filterCriteriaJsonString = '';
    columnHeaders = [];
    comboboxData = [];
    objectMdtList = [];
    filterPicklistFieldDropdown;
    filterFieldDate = [];
    filterFieldText = [];
    filterDateFieldValue = {};
    picklistFiltFldValueToApex = [];
    dateFiltFldValueToApex = [];
    textFiltFldValueToApex = [];
    lockedRecordsList = [];
    showLockedRecords = false;
    @track filterFieldsWrapper = {};
    @track sectionData = {};
    @track showCRMTransactions = false;
    @track isFilterFieldApplicale = false;
    @track objMdtRec = {};
    selectedSampleDate;
    @track isReportsOrDashboards = false;
    @track selectedAndUnselectedValues;
    @track bool = false;
    @track showUpdateButtonforRD = false;
    @track showUpdateOwnershipButtonForRD = false;
    @track showTextMessageforReportsDashboards = false;
    @track infoMsgForReportsDashboards ='';
    @track inforMsgForBatchSize ='';
    @track batchSize = 0;
    @track showAccountOptionsforToUsr = false;
    @track intelAccountValSelected = [];
    @track intelAccId;
    @track selectedIntelAccIdsNew=[];
    @track accSelectedNew = [];
    @track selectedRecords = 0;
    intelAccSelected = '';
    enableAccountFilter = false;
    columns = [];
    @track selectedRows=[];
    @track selectedRowsNew = [];
    showNodeAccountInFromUser = false;
    connectedCallback() {
        this.getApp();
    }
    getApp() {
        getAppData()
            .then((data) => {
                if (this.checkForUndefinedEmptyAndNull(data) && data !== {}) {
                    this.massOwnerMdtList = data.mdtList;
                    this.appOptions = data.applicationList;
                    this.appWithProgramList = data.appWithProgramList;
                    
                }
            })
            .catch(error => {
                this.error = error;
            });
    }
   
    get dynamiccolumns() {
        let col = Array.from(this.columnHeaders.entries()).map(([label, fieldName]) => {
            return {
                label: fieldName.label,              
                fieldName: fieldName.value,     
                type: 'text',              
                sortable: true,           
                disabled: false,           
            };
        });
        return col;
    }

    get showNodeAccountInFromUserCriteria(){
        return (this.isPartnerUser || this.showNodeAccountInFromUser);
    }

    handleAppFilterChange(event) {
        this.refreshToInitialSelection();//Refresh all the fields on change of App
        this.showFromUser = false;
        let selectedPlatform = event.target.value;
        if (selectedPlatform == 'CRM') {
            this.isCRMPlatform = true;
          
        }
        else {
            this.isCRMPlatform = false;
            this.disableProgram = false;
            this.disableObject = false;
           
        }
        let programOptionsList = [];
      
        let massOwnerMdtList = this.massOwnerMdtList; 
        programOptionsList = this.appWithProgramList!=null?this.appWithProgramList[selectedPlatform]:[];
        let isProgramApplicable = programOptionsList!=null?true:false;
        this.isProgramApplicable = isProgramApplicable;
        this.programOptions = programOptionsList;
        if(this.programOptions!=null){
            this.programOptions = [...this.programOptions]; // Create a copy before sorting
            this.programOptions.sort((a, b) => a.label.localeCompare(b.label));

        }
       
       
       
           
      
        this.appSelected = selectedPlatform;
        let objectOptions = [];
        if (this.isProgramApplicable== false) {

            Object.keys(massOwnerMdtList).forEach(key => {
                if(key == this.appSelected){
                    let mdtObjList = massOwnerMdtList[key];
                    mdtObjList.forEach(mdt => {
                        objectOptions.push({ label: mdt.Core_MDF_Object_Label_nm__c, value: mdt.Core_MDF_Object_apiName_nm__c, records: [] });
                        let filterVal = mdt.Core_MDF_Filter_Criteria_txt__c != null ? mdt.Core_MDF_Filter_Criteria_txt__c : '';
                        this.objectMdtList.push({ apiName: mdt.Core_MDF_Object_apiName_nm__c, value: mdt, filterVal: filterVal });

                    });

                }
              });
              this.objectOptions = objectOptions;
              
            this.objectOptions = objectOptions;
            this.objectOptions.sort((a, b) => a.label.localeCompare(b.label));
            this.objectOptions = this.objectOptions.sort();
            //this.showTypeOfFromUser = true;
           
        }
        else {
            this.objectOptions = []
            //this.showTypeOfFromUser = false;
            
        }
       
        if (this.appSelected != null) {
            this.disableApp = true;
        }
    }

    handleProgramFilterChange(event) {
        this.programValueSelected = event.target.value;
        //this.showTypeOfFromUser = true;
        if (this.programValueSelected != null) {
            this.disableProgram = true;
        }      

        let massOwnerMdtList = this.massOwnerMdtList;
        let objectOptions = [];
       
        Object.keys(massOwnerMdtList).forEach(key => {
            let appProgramKey = this.appSelected+this.programValueSelected;
            if(key == appProgramKey){
                let mdtObjList = massOwnerMdtList[key];
                mdtObjList.forEach(mdt => {
                    objectOptions.push({ label: mdt.Core_MDF_Object_Label_nm__c, value: mdt.Core_MDF_Object_apiName_nm__c, records: [] });
                    let filterVal = mdt.Core_MDF_Filter_Criteria_txt__c != null ? mdt.Core_MDF_Filter_Criteria_txt__c : '';
                    this.objectMdtList.push({ apiName: mdt.Core_MDF_Object_apiName_nm__c, value: mdt, filterVal: filterVal });

                });

            }
          });
        
        this.objectOptions = objectOptions;
        this.objectOptions.sort((a, b) => a.label.localeCompare(b.label));
        this.objectOptions = this.objectOptions.sort();

    }

    handleobjectFilterChange(event) {
        this.objectValueSelected = event.target.value;
        let fromUser =[];
        this.objMdtRec={};
        if( this.objectValueSelected == 'Reports' ||  this.objectValueSelected == 'Dashboards'){
            this.isReportsOrDashboards = true;
            this.showToUserDropdown = true;
            this.isInternalUser = true;
            this.showFromUser = true;
        }
    
        if (this.objectValueSelected != null) {
            this.disableObject = true;
        }
       
        let objIndex = this.objectMdtList.findIndex(obj => obj.apiName == this.objectValueSelected);
        this.objMdtRec = this.objectMdtList[objIndex].value;
        this.selectedObjectLabel =  this.objMdtRec.Core_MDF_Object_Label_nm__c;
        if(this.objMdtRec.Core_MDF_Type_of_From_User_nm__c!=undefined){
            //this.isInternalUser = true;
            this.showTypeOfFromUser = true;
            
        }
        else if(this.objMdtRec.Core_MDF_Type_of_From_User_nm__c==undefined){
            this.isInternalUser = true;
            this.showFromUser = true;
        }
        

        //let objectMdtRec = this.objectMdtList[objIndex].value;
        if (this.objectMdtList[objIndex].filterVal != '') {
            this.filterCriteriaJsonString = this.objectMdtList[objIndex].filterVal;
            this.isFilterFieldApplicale = true;
        }
        else{
            this.isFilterFieldApplicale = false;
        
           
        }
        if(this.objMdtRec.Core_MDF_Enable_Account_Filter_Ind__c == true && this.objMdtRec.Core_MDF_Account_Field_nm__c != ''){
            this.enableAccountFilter = true;
        }
       

        fromUser = this.objMdtRec.Core_MDF_Type_of_From_User_nm__c!=null?this.objMdtRec.Core_MDF_Type_of_From_User_nm__c.split(';'):null;
        if(fromUser!=null){
            let fromUsrOpt=[];
            let fromUsrValues = fromUser.forEach(opt => {
                fromUsrOpt.push({ label: opt, value: opt });
            });
            this.fromUserOptions = fromUsrOpt;
        }
        
            let columnHeaderMap = [];
            let columnHeaders = {};
            //columnHeaderMap = this.objMdtRec.Core_MDF_Column_Headers_txt__c.split(',');
            const keyValuePairs = this.objMdtRec.Core_MDF_Column_Headers_txt__c.split(','); // Split by comma
            keyValuePairs.forEach(pair => {
                const [key, value] = pair.split(':'); // Split by colon
                if (key && value) {
                    this.columnHeaders.push({label:key.trim(), value:value.trim()}); // Add to map, trimming whitespace
                }
            });
           
        if (this.isFilterFieldApplicale==true) {
            getFilterFieldWrapper({ filterCriteria: this.filterCriteriaJsonString })
                .then((data) => {
                    if (data != null) {
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

                            }
                            else if(key === 'text'){
                                value.forEach(val => {
                                    let filterFieldObj = {};
                                    filterFieldObj.label = val.label;
                                    filterFieldObj.apiName = val.apiName;
                                    filterFieldTxt.push(filterFieldObj);

                                })

                            }

                        }
                        this.filterPicklistFieldDropdown = filterFieldData;
                        this.filterFieldDate = filterFieldDt;
                        this.filterFieldText = filterFieldTxt;
                        //this.filterFieldOptionsList = fltOptions;

                    }
                })
                .catch(error => {
                    this.error = error;
                });
        }
    }
    handlePicklistFilterFieldChange(event) {
        const apiName = event.target.dataset.id;
        let fldFieldDropdownCopy =JSON.parse(JSON.stringify(this.filterPicklistFieldDropdown));
        let field = fldFieldDropdownCopy.find(item => item.apiName === apiName);
        field.value = JSON.parse(JSON.stringify(event.detail.value));
        const existingFieldIndex = this.picklistFiltFldValueToApex.findIndex(item => item.apiName === apiName);

        if (existingFieldIndex !== -1) {
            // If the field exists, update its value
            this.picklistFiltFldValueToApex[existingFieldIndex].value = field.value;
        } else {
            // If the field doesn't exist, add it
            this.picklistFiltFldValueToApex.push({ apiName: apiName, value: field.value });
        }
        this.filterFieldsWrapper.picklistFiltFldWrapList = this.picklistFiltFldValueToApex;
    }
        
    handleFilterDate(event) {
        const label = event.target.dataset.id;
        const field = this.filterFieldDate.find(item => item.label === label);
        const apiName = field.apiName;
        field.value = event.target.value;
       
        const existingFieldIndex = this.dateFiltFldValueToApex.findIndex(item => item.apiName === apiName);
        const context = field.label.includes("From")?'From':field.label.includes("To")?"To":'';
        const startDateRange = context==='From'?field.value:null;
        const endDateRage = context==='To'?field.value:null;

        if (existingFieldIndex !== -1) {
            // If the field exists, update its value
            if(context === "From"){
                this.dateFiltFldValueToApex[existingFieldIndex].startRange = startDateRange;
            }
            else if(context === "To"){
                this.dateFiltFldValueToApex[existingFieldIndex].endRange = field.value;
            }
        } else {
            // If the field doesn't exist, add it
            this.dateFiltFldValueToApex.push({ apiName: apiName, startRange: startDateRange,endRange: endDateRage });
        }
       
        this.filterFieldsWrapper.dtFiltFldWrapList = this.dateFiltFldValueToApex;

    }
    handleFilterText(event){
        const apiName = event.target.dataset.id;
        const field = this.filterFieldText.find(item => item.apiName === apiName);
        field.value = event.target.value;
        const existingFieldIndex = this.textFiltFldValueToApex.findIndex(item => item.apiName === apiName);

        if (existingFieldIndex !== -1) {
            // If the field exists, update its value
            this.textFiltFldValueToApex[existingFieldIndex].value = field.value;
        } else {
            // If the field doesn't exist, add it
            this.textFiltFldValueToApex.push({ apiName: apiName, value: field.value });
        }
        this.filterFieldsWrapper.txtFiltFldWrapList = this.textFiltFldValueToApex;
        
        
    }

    handleTypeofFromUserFilterChange(event) {
        this.typeOfFromUser = event.target.value;
        this.valueselected='';
        this.intelAccountValSelected = '';
        this.showNodeAccountInFromUser = false;
        this.refreshDataOnClickOfGetData();
        if (this.typeOfFromUser === 'Internal User') {
            
            this.isPartnerUser = false;
            this.showNodeAccountInFromUser = (this.programValueSelected == 'Retail Marketing Funds') ? true : false;
            this.showAccountOptions = true;
            
            //this.showIntelAccount = false;
            this.disableGetData = true;
        }
        else if (this.typeOfFromUser === 'External User') {
            this.isInternalUser = false;
           
            this.isPartnerUser = true;
            this.showAccountOptions = true;
            //this.showIntelAccount = true;
            this.disableGetData = true;
        }
        else if(this.typeOfFromUser === 'System User'){
           
            this.isPartnerUser = false;
            this.showAccountOptions = true;//To enable account for system user
            //this.showFromUser = true;
            //this.showIntelAccount = false;
            this.fromUserName = this.objMdtRec.Core_MDF_System_User_Name_txt__c;
            getUser({ userName: this.fromUserName, typeOfUser: this.typeOfFromUser, nodeAccountId: this.accountValueSelected,objConfigRec:this.objMdtRec })
            .then(result => {
                this.ownerName = result;
                if (result.length == 0) {
                    this.disableGetData = true;
                    this.messageFlag = true;
                    
                }
                else {
                    this.messageFlag = false;
                   
                    this.recId=result[0]['recId'];
                    this.valueselected =result[0]['recName'];
                  
                }
            })
            .catch(error => {
                console.log('error occured in handleTypeofFromUserFilterChange' + error);
                
            });
            

        }

        //fetch the account details only when he s a external user & internal user
       
        this.showToUser = false;
        
        
    }
    searchIntelAccount(event){
        this.intelAccSelected = event.target.value;
        if(event.target.value == ''){
            this.intelAccountValSelected = '';
            this.intelAccounts=[];
            this.intelAccId = null;  // Reset selected account ID
            this.accountValueSelected = null;  // Reset account value
            this.selectedIntelAccIdsNew = [];  // Clear the selected IDs list
            this.accSelectedNew = [];  // Clear the selected account objects list
            this.dynamiClassnamenew = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
            this.disableGetData = true;
            this.refreshDataOnClickOfGetData();
            return;
        }
        getAccounts({program:this.programValueSelected, accName:this.intelAccSelected})
        .then((data) => {
            this.intelAccounts = data;
            this.dynamiClassnamenew = data.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open slds-size_3-of-12' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';

            if(data.length==0){
                this.messageFlagForAcc = true;
            }
            else{
                this.messageFlagForAcc = false;
            }

        })
        .catch(error => {
            this.error = error;
        });
        
    }
    setSelectedAccount(event) {
        //this.intelAccountValSelected = [];
        this.intelAccId = event.currentTarget.dataset.id;
        const selectedIntelAccName = event.currentTarget.dataset.name;
        this.intelAccountValSelected = selectedIntelAccName;
        let newsObjectNew = { 'recId': this.intelAccId, 'recName': selectedIntelAccName };
        this.selectedIntelAccIdsNew.push(this.intelAccId);
        this.accSelectedNew.push(newsObjectNew);
        this.dynamiClassnamenew = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
        if(this.intelAccountValSelected!='' && (this.typeOfFromUser === 'Internal User' || this.typeOfFromUser === 'System User')){
            this.isInternalUser = true;
            this.showFromUser = true;
        }
        if(  this.valueselected!='' && this.intelAccountValSelected!=''){
           
            this.disableGetData = false; 
        }
        if(this.enableAccountFilter == true){
            this.accountValueSelected = this.intelAccId;
            this.intelAccId = null;
        }
        else{
        
        getNodeAccounts({ account:  this.intelAccId, program: this.programValueSelected })
            .then((data) => {
                if (this.checkForUndefinedEmptyAndNull(data) && data !== {} && Object.keys(data).length > 0) {
                    let accountOpt = [];
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
        
    }


    }

  
    handleFromNodeAccountFilterChange(event) {
        this.accountValueSelected = event.target.value;
        this.nodeToAccountSelected = event.target.value;
        this.showFromUser = true;
    }
    handleToNodeAccountFilterChange(event){
        if(this.isPartnerUser){
            this.nodeToAccountSelected =  this.accountValueSelected;
            this.disbaleToNodeAccount = true;

        }
        else{
        this.nodeToAccountSelected = event.target.value;
        }
        this.showToUserDropdown = true;
    }

    handleTypeOfToUserFilterChange(event) {
        this.typeofToUser = event.target.value;
        this.showToUserDropdown = true;
        this.showUpdateOwnershipButton = false;
        this.showAccountOptionsforToUsr = true;
        if(this.isReportsOrDashboards==false){
            this.recIdNew = null;
            this.valueselectedNew ='';
        }
        if(this.typeofToUser == 'External User'){
        this.isPartnerToUser = true;
        }
         else{
            this.isPartnerToUser = false;
        }
        if(this.isPartnerUser==true){
            this.nodeToAccountSelected = this.accountValueSelected;
            this.disbaleToNodeAccount = true;
        }
	 else{
            this.disbaleToNodeAccount = false;
        }
	if(this.typeofToUser == 'System User'){
            this.toUserName = this.objMdtRec.Core_MDF_System_User_Name_txt__c;
            getToUser({userName: this.toUserName, typeOfUser: this.typeofToUser, toNodeAccId: this.nodeToAccountSelected,intelAcc:this.intelAccId,objConfigRec:this.objMdtRec })
            .then(result => {
                this.toUserList = result;
                this.LoadingTextNew = false;
                if (result.length == 0) {
                    this.disableUpdateOwnershipButton = true;
                    this.messageFlagNew = true;
                }
                else {
                    this.messageFlagNew = false;
                    this.disableUpdateOwnershipButton = false;
                    this.recIdNew = result[0]['recId'];
                    this.valueselectedNew = result[0]['recName'];
                    this.showUpdateOwnershipButton = true;
                }
            })
            .catch(error => {
                const e = new ShowToastEvent({
                    title: 'Error',
                    message: applicationErrorMsg,
                    variant: 'error',
                    mode: 'dismissible'
                });
                this.dispatchEvent(e);
            });
        }
    }

    searchFromUser(event) {
        this.fromUserName = event.target.value;
        //this.LoadingText = true;
      
        if (this.fromUserName == '') {
            this.showTransactionDetails = false;
            this.showToUser = false;
            this.showUpdateButtonforRD = false;
            this.showOwnershipUpdatedRecords = false;
            this.dynamiClassname= 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
        }
        getUser({ userName: this.fromUserName, typeOfUser: this.typeOfFromUser, nodeAccountId: this.accountValueSelected,objConfigRec:this.objMdtRec })
            .then(result => {
                this.ownerName = result;
                //this.LoadingText = false;
                this.dynamiClassname = result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open slds-size_3-of-12' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
                if (result.length == 0) {
                    this.disableGetData = true;
                    this.messageFlag = true;
                    
                }
                else {
                    this.messageFlag = false;
                    //this.disableGetData = false;
                    
                }
            })
            .catch(error => {
                    const e = new ShowToastEvent({
                    title: 'Error',
                    message: applicationErrorMsg,
                    variant: 'error',
                    mode: 'dismissible'
                });
                this.dispatchEvent(e);
            });

    }
    getDataBasedOnSelAccntAndUser(event) {
        const fromUserUIElement = this.template.querySelector('[data-id="fromUserInputElement"]');
        this.recId = event.currentTarget.dataset.id;
        var selectName = event.currentTarget.dataset.name;
        if (fromUserUIElement) {
            fromUserUIElement.value = selectName;
        }
        this.valueselected = selectName;
        let newsObject = { 'recId': this.recId, 'recName': selectName };
        this.selectedIds.push(this.recId);
        this.ownerSelected.push(newsObject);
        this.dynamiClassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
        this.fromUserSelected = true;
        if(  this.valueselected!='' || (this.showAccountOptions==true && this.intelAccountValSelected !='')){
            this.disableGetData = false; 
        }
        else{
            this.disableGetData = true;
        }
    }

    getData() {
        this.showSpinner = true;
        this.batchSize = this.objMdtRec.Core_MDF_Batch_Size_nbr__c!=undefined ||this.objMdtRec.Core_MDF_Batch_Size_nbr__c!=null? this.objMdtRec.Core_MDF_Batch_Size_nbr__c:20;
        this.inforMsgForBatchSize = 'Only '+ this.batchSize+' records will be processed in one update';
        this.refreshDataOnClickOfGetData();
            getObjectTransactions({ program: this.programValueSelected, accountId: this.accountValueSelected,ultimateAccId:this.intelAccId,fromUser: this.recId, toUser:this.recIdNew, typeOfUser: this.typeOfFromUser, filtFldWrapper: this.filterFieldsWrapper, objConfigRec:this.objMdtRec,selectedIds: []}) 
                .then(response => {
                
                if (response) {
                    const data = response;
                this.recordsList = response;
                    this.records = data;
                    let result = [];
                    result = this.prepareTableData(data);
                    this.objRecordsList = [...result];
                    this.objRecordsListcount = this.objRecordsList.length;
                    this.hasRecords = this.objRecordsListcount > 0 ? true : false;
                   if (this.hasRecords) {
                    this.showTransactionDetails = true;
                    }
                    else {
                        const e = new ShowToastEvent({
                            title: 'Error',
                            message: 'No Records Present',
                            variant: 'error',
                            mode: 'dismissible'
                        });
                        this.dispatchEvent(e);
                    }
                    }
                else if (error) {
                    this.error = error;
                }
                this.showSpinner = false;
          })
            .catch(error => {
                this.showSpinner = false;
                const e = new ShowToastEvent({
                    title: 'Error',
                    message: applicationErrorMsg,
                    variant: 'error',
                    mode: 'dismissible'
                });
                this.dispatchEvent(e);
            });
      
       
    }
    getRefreshedData(){
        this.selectedRecords = 0;
        this.batchSize = this.objMdtRec.Core_MDF_Batch_Size_nbr__c!=undefined ||this.objMdtRec.Core_MDF_Batch_Size_nbr__c!=null? this.objMdtRec.Core_MDF_Batch_Size_nbr__c:20;
        this.inforMsgForBatchSize = 'Only '+ this.batchSize+' records will be processed in one update';
            getObjectTransactions({ program: this.programValueSelected, accountId: this.accountValueSelected,ultimateAccId:this.intelAccId,fromUser: this.recId, toUser:this.recIdNew, typeOfUser: this.typeOfFromUser, filtFldWrapper: this.filterFieldsWrapper, objConfigRec:this.objMdtRec,selectedIds: []}) 
                .then(response => {
                
                if (response) {
                    const data = response;
                //const error = response.error;
                this.recordsList = response;
                    this.records = data;
                    let result = [];
                    result = this.prepareTableData(data);
                    this.objRecordsList = [...result];
                    this.objRecordsListcount = this.objRecordsList.length;
                    this.hasRecords = this.objRecordsListcount > 0 ? true : false;
                   // this.showTransactionDetails = true;
                   if (this.hasRecords) {
                    this.showTransactionDetails = true;
                    }
                    else {
                        if(this.updatedRecordList.length <=0){
                        const e = new ShowToastEvent({
                            title: 'Error',
                            message: 'No Records Present',
                            variant: 'error',
                            mode: 'dismissible'
                        });
                        this.dispatchEvent(e);
                    }
                    }
                    }
                else if (error) {
                    this.error = error;
                }
          })
            .catch(error => {
                const e = new ShowToastEvent({
                    title: 'Error',
                    message: applicationErrorMsg,
                    variant: 'error',
                    mode: 'dismissible'
                });
                this.dispatchEvent(e);
            });
       
    }
    refreshDataOnClickOfGetData(){
        this.showUpdateOwnershipButton = false;
        this.showToUserDropdown = false;
        this.isPartnerToUser = false;
        this.showToUser = false;
        this.showOwnershipUpdatedRecords = false;
        this.selectedRowIds = [];//resetting selected rows list
        this.selectedRecords = 0;//resetting the selected records count
        this.selectedRowsNew=[];
        this.showTransactionDetails = false;
        this.showUpdateButtonforRD = false;
        this.showTextMessageforReportsDashboards = false;
        
        if(this.isReportsOrDashboards==false){
            this.recIdNew = null;
            this.valueselectedNew ='';
        }
        

    }
    refreshToInitialSelection() {
        this.appSelected = 'Select Application/Platform';
        this.programSelected = 'Select Program';
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
        this.objMdtRec = {};
        this.filterFieldsWrapper = {};
        this.programValueSelected = '';
        this.showUpdateButtonforRD = false;
        this.filterPicklistFieldDropdown;
        this.showAccountOptionsforToUsr = false;
        this.showAccountOptions = false;
        this.isPartnerToUser = false;
        this.valueselectedNew = '';
        this.showTextMessageforReportsDashboards = false;
        this.objectOptions = [];
        this.showToUserDropdown = false;
        this.disableGetData = true;
        this.intelAccountValSelected = [];
        this.enableAccountFilter = false;
        this.selectedRowIds = []; 
        this.recIdNew = null;
        this.recId = null;
        this.messageFlag = false;
        this.messageFlagNew = false;
	this.toUserOptions=[];
        this.fromUserOptions=[];
        this.objectMdtList=[];
        this.disbaleNodeAccount = true;
        this.disbaleToNodeAccount = true;
        this.showNodeAccountInFromUser = false;
    }
    searchToUser(event) {
        this.toUserName = event.target.value;
        this.LoadingTextNew = true;
        if (this.toUserName == "") {
            this.showUpdateOwnershipButton = false;
            this.showOwnershipUpdatedRecords = false;
            this.dynamicClassForToUser = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
        }
        getToUser({userName: this.toUserName, typeOfUser: this.typeofToUser, toNodeAccId: this.nodeToAccountSelected,intelAcc:this.intelAccId,objConfigRec:this.objMdtRec })
            .then(result => {
                this.toUserList = result;
                this.LoadingTextNew = false;
                this.dynamicClassForToUser = result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open slds-size_3-of-12' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
                if (result.length == 0) {
                    this.disableUpdateOwnershipButton = true;
                    this.messageFlagNew = true;
                }
                else {
                    this.messageFlagNew = false;
                    this.disableUpdateOwnershipButton = false;
                }
            })
            .catch(error => {
                const e = new ShowToastEvent({
                    title: 'Error',
                    message: applicationErrorMsg,
                    variant: 'error',
                    mode: 'dismissible'
                });
                this.dispatchEvent(e);
            });

    }
    setSelectedRecordNew(event) {
        const toUserUIElement = this.template.querySelector('[data-id="toUserInputElement"]');        
        this.recIdNew = event.currentTarget.dataset.id;
        var selectNameNew = event.currentTarget.dataset.name;
        if (toUserUIElement) {
            toUserUIElement.value = selectNameNew;
        }
        this.valueselectedNew = selectNameNew;
        let newsObjectNew = { 'recId': this.recIdNew, 'recName': selectNameNew };
        this.selectedIdsNew.push(this.recIdNew);
        this.ownerSelectedNew.push(newsObjectNew);
        this.dynamicClassForToUser = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
        if (this.ownerSelectedNew != [] && this.ownerSelectedNew.length > 0) {
            this.showUpdateOwnershipButton = true;
        }

    }
    handleRowSelected(event) {
        const selectedRows = event.detail.selectedRows;
        const selectedRowsLength = selectedRows.length;
        
        
        if (selectedRowsLength > this.batchSize) {
            // If yes, alert the user
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Selection Limit Exceeded',
                    message: `You can select at most ${this.batchSize} rows. If you select more records, it will pick via batch.`,
                    variant: 'info'
                })
            );

            // If limit exceeded, deselect the last selected row
           //this.selectedRows = this.selectedRows.slice(0, this.batchSize);
           this.selectedRowsNew = [];
        }
           this.selectedRows = selectedRows;
           this.selectedRowIds = [];//resetting selected rows list
           this.selectedRecords = 0;//resetting the selected records count
            for (let i = 0; i < this.selectedRows.length; i++) {
                this.selectedRowIds.push(this.selectedRows[i]["Id"]);
                this.selectedRecords =  this.selectedRowIds.length;
            }
            let typeOfTOUserOpt = [];
            this.selectedRowsNew = [...this.selectedRowIds];

            let toUser = this.objMdtRec.Core_MDF_Type_of_To_User_nm__c!=null?this.objMdtRec.Core_MDF_Type_of_To_User_nm__c.split(';'):null;
            if(toUser!=null){
                let toUsrValues = toUser.forEach(opt => {
                    typeOfTOUserOpt.push({ label: opt, value: opt });
                });
                this.toUserOptions = typeOfTOUserOpt;
            }


            
            this.showToUser = true;
       
            if (this.appSelected == 'CRM') {
                this.showToUserDropdown = true;
            }
            if(this.objectValueSelected==='Reports'||this.objectValueSelected==='Dashboards'){
                this.showUpdateOwnershipButtonForRD=true;
                this.showUpdateButtonforRD = true;
            }
       
    }

    updateOwnerOnSelectedRecords(event) {
        this.showSpinner = true;
        this.selectedRowIds = Array.from(new Set(this.selectedRowIds));
        if (this.recId == this.recIdNew) {
            this.showSpinner = false;
            const evt = new ShowToastEvent({
                variant: 'error',
                title: '',
                message: 'Existing user and New user cannot be same'
            });
            this.dispatchEvent(evt);
            this.error = true;
        }
        else{
        if(this.isReportsOrDashboards){
            shareReportFolder({selectedRowIds:this.selectedRowIds,toUser: this.recIdNew,obj: this.objectValueSelected,objConfigRec:this.objMdtRec})
                .then(result=>{
                    let res=result;
                    if(res){
                        this.showTextMessageforReportsDashboards = true;
                        this.infoMsgForReportsDashboards = this.objectValueSelected+' access for the selected row/s will be completed in some time. Please try accessing the '+this.objectValueSelected+ ' after a few minutes.';
                        const evt1 = new ShowToastEvent({
                            title: 'Info',
                            message: this.infoMsgForReportsDashboards,
                            variant: 'info',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt1);
                        this.showSpinner = false;
                    }
                }).
                catch(error => {
		    this.showSpinner = false;
                    const e = new ShowToastEvent({
                    title: 'Error',
                    message: applicationErrorMsg,
                    variant: 'error',
                    mode: 'dismissible'
                });
                this.dispatchEvent(e);
                });
            }
        else{
            updateOwner({ selectedRowIds: this.selectedRowIds, toUser: this.recIdNew, obj: this.objectValueSelected, objConfigRec:this.objMdtRec})
                .then(result => {
                    let bool = result.res;
                    let updatedRecordList = result.updatedRecordsList;
                    let failedRecCount = result.failedRecCount!=undefined?result.failedRecCount:0;
                    let successRecCount = result.updatedRecordsList!=undefined?updatedRecordList.length:0;
                    if(failedRecCount > 0 && successRecCount > 0){
                        this.updatedRecordList = this.prepareTableData(updatedRecordList);
                        
                        this.showOwnershipUpdatedRecords = (this.updatedRecordList !== [] && this.updatedRecordList.length > 0) ? true : false;
                        const e = new ShowToastEvent({
                            title: 'Info',
                            message: failedRecCount+' records are failed to update and '+successRecCount+' records are successfully updated, please check the log entry for complete details',
                            variant: 'Info',
                            mode: 'dismissible'
                        });
                        this.dispatchEvent(e);

                        this.getRefreshedData();
                        this.showSpinner = false;
                        
                    }
                    else if(failedRecCount == this.selectedRowIds.length && successRecCount == 0){
                        this.showOwnershipUpdatedRecords = false;
                        this.showSpinner = false;
                        const e = new ShowToastEvent({
                            title: 'Error',
                            message: 'No Records got updated, please check the log entry for complete details',
                            variant: 'error',
                            mode: 'dismissible'
                        });
                        this.dispatchEvent(e);
                        return;

                    }
                    else if (failedRecCount == 0 && successRecCount == this.selectedRowIds.length) {
                        

                            this.updatedRecordList = this.prepareTableData(updatedRecordList);
                            this.showOwnershipUpdatedRecords = (this.updatedRecordList !== [] && this.updatedRecordList.length > 0) ? true : false;
                            const evt = new ShowToastEvent({
                                title: 'Success',
                                message: 'All records are updated successfully',
                                variant: 'success',
                                mode: 'dismissible'
                            });
                            this.dispatchEvent(evt);
                        this.getRefreshedData();
                        this.showSpinner = false;

                    }
                    else if(result.isBatchExecution == true){
                        const evt = new ShowToastEvent({
                            title: 'Info',
                            message: 'Ownership transfer is in progress, you will be notified via email once it is completed',
                            variant: 'Info',
                            mode: 'dismissible'
                        });
                        this.dispatchEvent(evt);
                        this.getRefreshedData();
                        this.showSpinner = false;
                    }
                }).catch(error => {
                    this.showSpinner = false;
                    const e = new ShowToastEvent({
                    title: 'Error',
                    message: applicationErrorMsg,
                    variant: 'error',
                    mode: 'dismissible'
                });
                this.dispatchEvent(e);
                });
            refreshApex(this.objRecordsList);
        }
        }

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
    
    prepareTableData(data) {
        let result = [];
        this.lockedRecordsList = [];
        if (data && data.length > 0) {
            data.forEach(record => {
                if (record.isRecordLockedInd) {
                    this.lockedRecordsList.push({ ...record });
                } else {
                    const row = { ...record };
                    result.push(row);
                }
            });
        }
        if(this.lockedRecordsList.length > 0)
            this.showLockedRecords = true;
        else
            this.showLockedRecords = false;
        return result; 
    }
    getSystemUser(userNameTxt){
        getUser({ userName: userNameTxt, typeOfUser: this.typeOfFromUser, nodeAccountId: this.accountValueSelected,objConfigRec:this.objMdtRec })
        .then(result => {
            this.ownerName = result;
            if (result.length == 0) {
                this.disableGetData = true;
                this.messageFlag = true;
                console.log('no record');
            }
            else {
                this.messageFlag = false;
                //this.disableGetData = false;
               
                console.log('record present');
            }
        })
        .catch(error => {
            console.log('-------error-------------' + error.body.message);
            console.log(error);
        });
    }
    
}