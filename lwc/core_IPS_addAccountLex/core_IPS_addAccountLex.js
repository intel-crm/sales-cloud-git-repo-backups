import { LightningElement, api, wire} from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExistingAccounts from '@salesforce/apex/Core_IPS_ProjectController_Lex.getExistingAccounts';
import checkExistingAccounts from '@salesforce/apex/Core_IPS_ProjectController_Lex.checkExistingAccounts';
import getAddAccounts from '@salesforce/apex/Core_IPS_ProjectController_Lex.getAddAccounts';
import insertAccount from '@salesforce/apex/Core_IPS_ProjectController_Lex.insertAccount';
import hasProjectEditAccess from '@salesforce/apex/Core_IPS_ProjectController_Lex.hasProjectEditAccess';
import detailPage from '@salesforce/label/c.Core_IPS_Project_Detail_Page';
import UcdToggleSwitch from "@salesforce/label/c.Core_IPS_UCD_Toggle_Switch";
import Project_AllMemberType_Message from "@salesforce/label/c.Core_IPS_Project_AllMemberType_Message";
import Project_AllMemberType_MessageTimeLimit from "@salesforce/label/c.Core_IPS_Project_AllMemberType_MessageTimeLimit";
const actions = [
        { label: 'Selective', name: 'Selective' },
        { label: 'All', name: 'All' }
];

export default class Core_IPS_addAccountLex extends NavigationMixin(LightningElement) {
    
    @api recordId;
    existingData =[];
    accntIds =[];
    activeSections=['A','B'];
    accountsData =[];
    recsToInsert = [];
    recsToInsertId = [];
    clonedSelectedIds=[];
    hasItemsToInsert = false;
    rowLimit =10;
    rowOffSet=0;
    searchText;
    tempRecordId;
    cnt=0;
    searchMsg = false;
    showTable = true;
    showButton = true;
    projAccess = true;
    showExAcc = true;
    customsortDirection = 'asc';
    sortedBy = 'name';
    existingSortedBy = 'name';
    existingSortDirection = 'asc';
    pickListData = [];
    accountRecords = [];
    spinner = true;
    loading = false;
    enableSorting = false;
    isMemberTypeAll = false;
    inactiveAccIds = [];//Added by Nuthana
    Project_AllMemberType_Msg = Project_AllMemberType_Message;
    currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.recordId = this.currentPageReference?.state?.c__recordId;
        if(this.cnt==1&&this.recordId!=this.tempRecordId){
           window.location.reload();
        }
    }
    projectrecordId() {
        if(this.currentPageReference != null && this.currentPageReference != undefined){
            return this.currentPageReference?.state?.c__recordId;
        }        
    }   
    connectedCallback() {
        this.columns = [
            { label: 'Account Name', fieldName: 'name', type: 'text',sortable: true},
            { label: 'Account Owner', fieldName: 'owner', type: 'text',sortable: true},
            { label: 'Account ID', fieldName: 'accid', type: 'text',sortable: true},
            //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id
            { label: 'Unified ID', fieldName: 'unifiedid', type: 'text',sortable: true},
            {
                label: 'Members', fieldName: 'Members', type: 'picklist', editable:true, fixedWidth: 225, typeAttributes: {
                    placeholder: 'Member Type', options: [
                        { label: 'Selective', value: 'Selective' },
                        { label: 'All', value: 'All' },
                    ]  
                    , value: { fieldName: 'Members' }  
                    , context: { fieldName: 'name' }
                }
            },
            { label: 'cnda', fieldName: 'cnda', type: 'text', }
            
        ];  
        if(this.columns.length >= 5 && UcdToggleSwitch === '0') {
            this.columns[3] = { label: 'CIM ID', fieldName: 'cimid', type: 'text',sortable: true};

        }
        
         this.columns = this.columns.filter(col =>(col.label !== 'cnda'));
        this.existColumns = [
            { label: 'Account Name', fieldName: 'name', sortable: true, type: 'text' },
            { label: 'Account Owner', fieldName: 'owner', sortable: true, type: 'text' },
            { label: 'Account ID', fieldName: 'accid', sortable: true, type: 'text' },
            //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id
            { label: 'Unified ID', fieldName: 'unifiedid', sortable: true, type: 'text' },
            { label: 'Members', fieldName: 'members', sortable: true, type: 'text' }
        ];  

        if(this.existColumns.length >= 4 && UcdToggleSwitch === '0') {
            this.existColumns[3] = { label: 'CIM ID', fieldName: 'cimid', type: 'text',sortable: true};

        }
        
        this.recordId = this.projectrecordId();  
        this.tempRecordId = this.recordId;
        this.cnt=1;          
        this.hasProjectEditAccess();
        this.checkExistingAccounts();
        this.getExistingAccounts();
    }
    checkExistingAccounts() {
        checkExistingAccounts( {
            projectId : this.recordId
        })
        .then(data=>{
            if(data != null && data != undefined && data != '' && data==true){
                this.dispatchEvent(new ShowToastEvent({
                  message: 'Any existing Account must have a CNDA prior to adding additional Accounts to a Premier Support Project',
                  variant: 'error',
                }));
                this.projAccess = false;
            }
        })
        .catch(error=>{
               console.log(' Error Occured:  '+error.message);
        })
    }            
    getExistingAccounts() {
        getExistingAccounts( {
            projectId : this.recordId
        })
        .then(data=>{
            if(data){
                for (let i = 0; i < data.length; i++) {
                    let obj = {
                        'Id' : data[i].Id,
                        'name' : data[i].Core_Account__r.Name,
                        'owner' : data[i].Core_Account__r.Owner.Name,
                        'accid' : data[i].Core_Account__r.Id,
                        //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id
                        'unifiedid' : data[i].Core_Account__r.Core_Business_Party_Id__c,
                        'members' : data[i].Core_Members__c
                    };
                    if(UcdToggleSwitch === '0') {
                        delete obj.unifiedid;
                        
                        Object.defineProperty(obj, 'cimid', {value: data[i].Core_Account__r.Core_CIM_ID__c});
                        
                    } 
                    this.existingData = [...this.existingData, obj];
                    //this.accntIds = [...this.accntIds, data[i].Core_Account__c]; commented by Nuthana
                    if(data[i].Core_Status__c === 'Active'){
                        this.accntIds = [...this.accntIds, data[i].Core_Account__c];
                    }
                    else {
                        this.inactiveAccIds = [...this.inactiveAccIds, data[i].Core_Account__c];
                    }
                    
                    
                }
                 
            }
            else{
                this.showExAcc = false;
            }
            this.getAccounts('Load Data');
        })
        .catch(error=>{
            console.log(' Error Occured:  '+error.message);
        })
    }

    getAccounts(mssg){
        this.loading = true;
        return getAddAccounts({
            accIds :  this.accntIds,
            limitSize : this.rowLimit,
            offset : this.rowOffSet,
            fetchType : mssg,
            searchText : this.searchText
        })
        .then( data => {
            if(data) {
                
                if(this.searchText != undefined && this.searchText != '' && this.searchText != null && this.searchText.length >= 3){
                   this.accountsData = [];
                } 
                  
                for (let i = 0; i < data.length; i++) {
                    if(this.inactiveAccIds.includes(data[i].Id)) continue;//Added By Nuthana
                    let obj = {
                        'name' : data[i].Name,
                        'owner' : data[i].Owner.Name,
                        'accid' : data[i].Id,
                        //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id
                        'unifiedid' : data[i].Core_Business_Party_Id__c,
                        'Members':'Selective',
                        'cnda' : data[i].Core_CNDA_Number__c
                    };
                    if(UcdToggleSwitch === '0') {
                        delete obj.unifiedid;
                        Object.defineProperty(obj, 'cimid', {value: data[i].Core_CIM_Id__c});
            
                    }
                    this.accountsData = [...this.accountsData, obj];
                    console.log(obj);
                }
            }
            this.rowOffSet = this.rowOffSet + this.rowLimit;
            //if(this.accountsData.length == 0 && this.searchText.length >= 3){ - Commented by Nuthana
            if(this.accountsData.length == 0 && this.searchText && this.searchText.length >= 3){
               
                this.showTable = false;
            }
            else{
                //this.loading = false;
                this.showTable = true;
            }
            this.loading = false;
            let tempAccId = this.recsToInsertId;
            this.clonedSelectedIds = JSON.parse(JSON.stringify(tempAccId));
            console.log('clonedids==='+JSON.stringify(this.clonedSelectedIds));
            if(this.accountsData.length != 0 && this.enableSorting){
                this.accountRecords = this.accountsData;
                this.sortData(this.sortedBy,this.customsortDirection,this.accountRecords,'accountsData');
            }
            
            
        })
        .catch(error=>{
            console.log(' Error: '+error.message);
            this.loading = false;
        })
    }

    handleLoadMore(event) {
        if(this.searchText != undefined && this.searchText != '' && this.searchText != null && this.searchText.length != 0) return;
        const { target } = event;
        target.isLoading = true;   
        this.getAccounts('Load Data').then(()=> {
            target.isLoading = false;
        });
    }

    handleKeyChange(event) {      
        console.log('Hk 230');
     
        this.searchText = event.target.value; 
        this.rowOffSet = 0;
        this.accountsData = [];
       // this.recsToInsert = [];
        //console.log('@@@@@ pavani >>> Key' , JSON.stringify(this.recsToInsert ));
        this.evaluateSelected();  
        //console.log('@@@@@ pavani >>> key1 ' , JSON.stringify(this.recsToInsert )); 
        if(this.searchText.length >=3){ 
            this.searchMsg = false;      
           // console.log('@@@@@ pavani >>> key3 ' , JSON.stringify(this.recsToInsert ));    
            this.getAccounts('All Data');
           // console.log('@@@@@ pavani >>> key4 ' , JSON.stringify(this.recsToInsert ));
        }
        else{
            if(this.searchText.length >= 1 && this.searchText.length < 3)
                this.searchMsg = true;
            else
                this.searchMsg = false;    
            this.searchText = '';
            //console.log('@@@@@ pavani >>> key5 ' , JSON.stringify(this.recsToInsert ));
            this.getAccounts('Load Data');
           // console.log('@@@@@ pavani >>> key6 ' , JSON.stringify(this.recsToInsert ));
        }
    }

    getSelected(event) {
        console.log('@@@@@ pavani >>> ' , JSON.stringify(this.recsToInsert ));
        console.log("selected rows" + JSON.stringify(event.detail.selectedRows));
        console.log("selected rows1" + JSON.stringify(event.detail));
        /*let tempsel = []; "selection":"rowSelect"rowDeselect
        tempsel = JSON.parse(JSON.stringify(event.detail.selectedRows));
        let copyOfRecToInsert = [...this.copyOfRecToInsert, ...tempsel];
        */
       let selectedRowIds=this.recsToInsertId;
        console.log('Hk 264>> ', event.detail.config.value);
        console.log('Hk 265>> ', event.detail.config.selection);
        if(event.detail.config.selection == 'rowDeselect'){
            console.log('Deselection');
            this.recsToInsert = this.recsToInsert.filter(item => item.accid != event.detail.config.value);
            selectedRowIds = selectedRowIds.filter(item => item != event.detail.config.value);
    
            console.log('@@@@@ pavani after deselection >>> ' , JSON.stringify(this.recsToInsertId ));
        }
        else{
            
            if(!selectedRowIds.includes(event.detail.config.value)){
                console.log('@@@@@ pavani First If>>> ' , JSON.stringify(this.recsToInsert ));
                selectedRowIds.push(event.detail.config.value);
                event.detail.selectedRows.forEach(element => {
                    console.log('@@@@@ pavani For >>> ' ,event.detail.config.value+'--'+element.accid );
                    if(event.detail.config.value==element.accid){
                        console.log('@@@@@ pavani If >>> ' , JSON.stringify(this.recsToInsert ));
                        this.recsToInsert.push(element);
                    }
                });
                
            }
        }
       this.recsToInsertId = selectedRowIds;
        console.log('@@@@@ pavani after push >>> ' , JSON.stringify(this.recsToInsert ));
        //console.log('@@@@@ pavani >>> copy after ' , copyOfRecToInsert );


      //  this.recsToInsert = this.reevent.detail.selectedRows;
        this.evaluateSelected();
        
    }
    evaluateSelected() {
        if (this.recsToInsert.length == 0) this.hasItemsToInsert = false;
        else this.hasItemsToInsert = true;
    }

    hasProjectEditAccess(){
        hasProjectEditAccess({
            projectId: this.recordId
        })
        .then(data=>{
            if(data==true)
                this.projAccess = true;
            else{
                this.projAccess = false;
                const event = new ShowToastEvent({
                   message: 'You do not have permission to Add Account.',
                   variant: 'error',
                });
                this.dispatchEvent(event);
                this.showButton = false;
            }
            this.spinner = false;
        })
        .catch(error=>{
            console.log('error occured: '+error);
        })
    }

    //@api
    handleAdd(event) { 
        this.spinner= true;
        this.isMemberTypeAll = false;      //As part of Vulnerability Fix 
        var param = event.currentTarget.dataset.key;
        if(this.recsToInsert.length == 0){
            this.dispatchEvent(new ShowToastEvent({
                message: 'Please Select atleast one Account',
                variant: 'Info',
            }));
            this.spinner = false;
        }
        else{
            var finalList = [];
            for(let i = 0; i<this.recsToInsert.length;i++) {
                finalList = [...finalList , JSON.stringify(this.recsToInsert[i])];
                if(this.recsToInsert[i].Members == 'All' && this.isMemberTypeAll == false){
                    console.log('adding acct if conditon');
                    this.isMemberTypeAll = true;
                }
            }
            insertAccount({
                inputStrings: finalList,
                projId : this.recordId
            })
            .then(data=>{
                this.showSpinner = true;
                if(data === 1){
                    this.dispatchEvent(new ShowToastEvent({
                        message: 'Accounts added sucessfully',
                        variant: 'success',
                    }));  
                    if(this.isMemberTypeAll == true){
                        console.log('addin acct warbing message');
                        this.dispatchEvent(new ShowToastEvent({
                            message: Project_AllMemberType_Message,
                            variant: 'warning'
                            /*mode: 'sticky'*/
                        }));
                    } 
                    if(param === 'Add'){                
                        if(this.isMemberTypeAll == true){
                            setTimeout(() => {window.location.reload();}, Project_AllMemberType_MessageTimeLimit);
                        }               
                        else{ window.location.reload(); }
                    } else if (param ==='AddDone'){
                        if(this.isMemberTypeAll == true){
                            setTimeout(() => {this.handleCancel();}, Project_AllMemberType_MessageTimeLimit);
                        }               
                        else{ this.handleCancel();}
                    }
                }
                if(data === 2){
                    this.dispatchEvent(new ShowToastEvent({
                        message: 'Unable to Add Accounts',
                        variant: 'error',
                    })); 
                    this.spinner = false;
                    this.resetSelection();//As part of Vulnerability Fix
                }
                if(data === 3){
                    this.dispatchEvent(new ShowToastEvent({
                        message: 'Projects with multi-party Accounts should only have Accounts with NDAs',
                        variant: 'error',
                    })); 
                    this.spinner = false;
                    this.resetSelection(); //As part of Vulnerability Fix 
                }
                if(data === 4){
                    this.dispatchEvent(new ShowToastEvent({
                        message: 'A valid MPNDA is required prior to adding secondary Accounts to a Premier Support Project',
                        variant: 'error',
                    })); 
                    this.spinner = false;
                    this.resetSelection();//As part of Vulnerability Fix 
                }
            })
            .catch(error=>{
                console.log('error occured: '+JSON.stringify(error));
                this.spinner = false;
                this.resetSelection(); //As part of Vulnerability Fix            
            })
        }
    }

    handleCancel(){
        window.location.href = detailPage+this.recordId+'/view';
    }
    picklistChanged(event) {
        let memVal = event.detail.data.value;
        let recName = event.detail.data.context;
        this.accountsData.find(eachaccountsData => eachaccountsData.name === recName).Members = memVal;
    }

    handleSortExisting(event) {        
        this.existingSortedBy = event.detail.fieldName;       
        this.existingSortDirection = event.detail.sortDirection;       
        this.sortData(this.existingSortedBy,this.existingSortDirection ,this.existingData,'existingData');
    }

    handleAccountSort(event){
        this.enableSorting = true;
        this.sortedBy = event.detail.fieldName;       
        this.customsortDirection = event.detail.sortDirection;
        this.accountRecords = this.accountsData;
        this.sortData(this.sortedBy,this.customsortDirection,this.accountRecords,'accountsData');       
    }
    //Added this method as once the mpnda error is shown, the recsToInsert is not resetting and its showing the error message again - Nuthana(As part of Vulnerability Fix - deffered issue)
    resetSelection() {
    this.recsToInsert = [];
    this.recsToInsertId = [];
    this.clonedSelectedIds = [];
    this.evaluateSelected();
    }
    sortData(fieldname, direction,inputData,type) {       
        let parseData = JSON.parse(JSON.stringify(inputData));  
        let sortedData = (key) => {
            return key[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
            parseData.sort((x, y) => {               
                x = sortedData(x) ? sortedData(x).toLowerCase() : ''; 
                y = sortedData(y) ? sortedData(y).toLowerCase() : '';  
                return isReverse * ((x > y) - (y > x));
            });
            if(type == 'existingData'){
                this.existingData = parseData; 
            } 
            else if(type == 'accountsData'){
                this.accountsData = [];
                this.accountsData = parseData;
            }  
    }
}