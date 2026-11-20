import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

import getProgPicklistValues from '@salesforce/apex/Core_MDF_RecoveryDashboardController.getProgramIdToNameMap';
import getAccountPicklistValues from '@salesforce/apex/Core_MDF_RecoveryDashboardController.getAccountIdToNameMap';
import getQuarterPicklistValues from '@salesforce/apex/Core_MDF_RecoveryDashboardController.getQuarterOptionsMap';
import getRecMappingRec from '@salesforce/apex/Core_MDF_RecoveryDashboardController.getPartnershipScoreRecord';


//Custom Labels
import programLabel from '@salesforce/label/c.Core_MDF_Program';
import accountLabel from '@salesforce/label/c.Core_MDF_Channel_Partner';
import quarterLabel from '@salesforce/label/c.Core_MDF_Quarter';
import selectProgram from '@salesforce/label/c.Core_MDF_LWC_SelectProgram_Label';
import selectAccount from '@salesforce/label/c.Core_MDF_LWC_SelectAccount_Label';
import selectQuarter from '@salesforce/label/c.Core_MDF_LWC_SelectQuarter_Label';
import getDataLabel from '@salesforce/label/c.Core_MDF_GetData';
import recoveryDashboard from '@salesforce/label/c.Core_MDF_LWC_RecoveryDashboardLabel';
import recoveryRecordNotPresesntMessage from '@salesforce/label/c.Core_MDF_LWC_RecoveryDashboardError';
import partnerCommunityURL from '@salesforce/label/c.Core_MDF_PFRCommunityLink';


export default class Core_MDF_Recovery_Dashboard extends NavigationMixin(LightningElement) {//this class needs to be changed?
    accountNotLoaded = true;
    quarterNotLoaded = true;
    allOptionsNotSelected = true;
    @track isRecoveryRecordNotPresent = false;
    isLoading = false
    showDropdowns = true;
    bypassSharing = true;
    

    //Custom Labels--start
    programLabel = programLabel;
    accountLabel = accountLabel;
    quarterLabel = quarterLabel;
    selectProgram = selectProgram;
    selectAccount = selectAccount;
    selectQuarter = selectQuarter;
    getDataLabel = getDataLabel;
    recoveryDashboard = recoveryDashboard;
    recoveryRecordNotPresesntMessage = recoveryRecordNotPresesntMessage;

    //Custom labels--end

    programOptions = [];
    accountOptions = [];
    quarterOptions = [];

    @track accountValueSelected = '';
    @track quarterValueSelected = '';
    recordId = '';

    programValueSelected = '';
    programSelectedId = '';
    accValueSelected = '';
    accountSelected = '';
    quarterSelected = '';
    //isDataNull = true;

    isExternalUser = false;
    accountQueryFilter = '';
    listOfAccIdsCommaSeparated = '';
    queryParams={};

    @api showHeader = false;

    @track selectedOptions = { account: this.accountValueSelected, program: this.programValueSelected, quarter: this.quarterValueSelected, mode: this.mode, budgetType: this.selectedBT };

    @api item = { data: null, errors: null };

    connectedCallback() {
        this.getPrograms();
        
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log(currentPageReference);
            if (currentPageReference.state !== {} && Object.keys(currentPageReference.state).length) {
                console.log('svdrsvs ')
                this.queryParams = {
                    programId: currentPageReference.state.c__programId,
                    accountId: currentPageReference.state.c__accountId,
                    quarterYear: currentPageReference.state.c__quarterYear,
                    isRecovRecNotPresent:currentPageReference.state.c__isRecovRecNotPresent,
                };
            }
        }
    }
    getData() {
        this.isRecoveryRecordNotPresent = false;
        getRecMappingRec({ program: this.programSelectedId, account: this.accValueSelected, quarter: this.quarterValueSelected })
            .then((data) => {
                if(this.checkForUndefinedEmptyAndNull(data) && data.length == 1){
                    let recordId = data[0].Id;
                    this.getLink(recordId);
                }else{
                    this.isRecoveryRecordNotPresent = true;
                    if(!this.isExternalUser){
                        this.navigateToTabPage();
                    }else{
                        this.navigateToExtUserTabPage();
                    }
                } 
            })
            .catch(error => {
                this.error = error;
                this.logErrorMessage(error);
            });
               
    }
    logErrorMessage(e){
        const event = new ShowToastEvent({
            title: 'Error',
            message: e,
            variant: 'error',
            mode: 'pester'
        });
        console.log(e);
        //this.dispatchEvent(event);
    }

    getLink(input) {
        
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: input,
                objectApiName: 'Core_MDF_Partnership_Score__c',
                actionName: 'view',
                
            },
            state: {
                c__programId:this.programSelectedId,
                c__accountId:this.accValueSelected,
                c__quarterYear:this.quarterValueSelected ,
                c__isRecovRecNotPresent:this.isRecoveryRecordNotPresent
            }
        }).then(url => {
            window.open(url, "_self");//to open in a new tab
        });
        //this.isRecoveryRecordNotPresent = false;
    }
    navigateToExtUserTabPage() {
        this[NavigationMixin.Navigate](
        { 
            "type": "standard__webPage", 
            "attributes": 
            { 
                "url": partnerCommunityURL+"s/recovery-dashboard/?c__programId="+this.programSelectedId+"&c__accountId="+this.accValueSelected+"&c__quarterYear="+this.quarterValueSelected+"&c__isRecovRecNotPresent="+this.isRecoveryRecordNotPresent 
            }, 
         }); 
    }
    navigateToTabPage() {
        
        // Navigate to a specific CustomTab.
        this[NavigationMixin.Navigate]({
          type: "standard__navItemPage",
          attributes: {
            // CustomTabs from managed packages are identified by their
            // namespace prefix followed by two underscores followed by the
            // developer name. E.g. 'namespace__TabName'
            apiName: "Recovery_Dashboard",
          },
          state: {
            c__programId:this.programSelectedId,
            c__accountId:this.accValueSelected,
            c__quarterYear:this.quarterValueSelected ,
            c__isRecovRecNotPresent:this.isRecoveryRecordNotPresent
        }
        });
        // if(this.checkForUndefinedEmptyAndNull(this.queryParams.isRecovRecNotPresent) &&  this.queryParams !={} && Object.keys(this.queryParams).length){
        //             this.isRecoveryRecordNotPresent = this.queryParams.isRecovRecNotPresent;
        // }
      }

    getPrograms() {
        debugger;
        console.log('currentPageReference 135',this.queryParams);
        let qrParams = this.queryParams;
        getProgPicklistValues()
            .then((data) => {
                if(this.checkForUndefinedEmptyAndNull(data)){
                    for (let i = 0; i < data.programDetailsList.length; i++) {
                        this.programOptions = [...this.programOptions, { value: data.programDetailsList[i].progId, label: data.programDetailsList[i].progname}];
                    }
                    console.log('program data', data);
                    if (data.isUserExternal) {
                        if(data.programDetailsList.length == 1 && this.programOptions.length == 1){
                            let programOpt = this.programOptions[0];
                            if(programOpt != undefined ){
                                this.isExternalUser = true;
                                //this.programSelectedId = programOpt.id;
                                this.programSelectedId = programOpt.value;
                                this.programValueSelected = programOpt.label;   
                                this.getAccounts(this.programValueSelected);
                            }
                            console.log('Print-> ',programOpt);
                        }else if(this.checkForUndefinedEmptyAndNull(qrParams.programId)&&  qrParams !={} && Object.keys(qrParams).length) {
                            this.programSelectedId = qrParams.programId;
                            this.programValueSelected = this.programOptions.find(opt => opt.value === this.programSelectedId).label;
                            //this.programOptions.find(opt => opt.value == event.detail.value).label;
                            this.getAccounts(this.programValueSelected);
                        }
                    }else if(this.checkForUndefinedEmptyAndNull(qrParams.programId)&&  qrParams !={} && Object.keys(qrParams).length){
                            this.programSelectedId = qrParams.programId;
                            this.programValueSelected = this.programOptions.find(opt => opt.value === this.programSelectedId).label;
                            //this.programOptions.find(opt => opt.value == event.detail.value).label;
                            this.getAccounts(this.programValueSelected);
                    }
                }
                if(this.checkForUndefinedEmptyAndNull(qrParams.isRecovRecNotPresent) &&  qrParams !={} && Object.keys(qrParams).length){
                    this.isRecoveryRecordNotPresent = JSON.parse(qrParams.isRecovRecNotPresent);
                }
            })
            .catch(error => {
                this.error = error;
                this.logErrorMessage(error);
            });
    }

    getAccounts(prog) {
        debugger;
        this.isLoading = true;
        let accIds = [];
        let qrParams = this.queryParams;
        getAccountPicklistValues({ program: prog })
            .then((data) => {
                if(this.checkForUndefinedEmptyAndNull(data)){
                    this.accountNotLoaded = false;

                    //this.listOfAccIdsCommaSeparated = '(';
                    for (let i = 0; i < data.accountDetailsList.length; i++) {
                        if (!this.accountOptions.find(opt => opt.value == data.accountDetailsList[i].accountId)) {
                            accIds.push("'" + data.accountDetailsList[i].accountId + "'");
                            this.listOfAccIdsCommaSeparated = this.listOfAccIdsCommaSeparated +'\'' + data.accountDetailsList[i].accountId + '\'';//id in ('','')
                            if(i < data.accountDetailsList.length - 1){
                                this.listOfAccIdsCommaSeparated = this.listOfAccIdsCommaSeparated + ',';
                            }
                            this.accountOptions = [...this.accountOptions, { value: data.accountDetailsList[i].accountId, label: data.accountDetailsList[i].accountName }];

                        }

                    }
                    if (data.accountDetailsList.length == 0) {
                        this.accountQueryFilter = " Id = '' ";
                    } else {
                        this.listOfAccIdsCommaSeparated = '(' + accIds + ')';
                        this.accountQueryFilter = " Id In " + this.listOfAccIdsCommaSeparated + ' order by Name';
                    }
                    if (data.isUserExternal) {
                        this.isExternalUser = true;

                        if (this.accountOptions.length == 1) {
                            let accountOpt = this.accountOptions[0];
                            if (accountOpt != undefined) {
                                //this.isExternalUser = true;
                                this.template.querySelector('c-core_-m-d-f_-custom-lookup').selectAccountOnRecoveryIfOneAccOnly(data.accountDetailsList);
                                this.accValueSelected = accountOpt.value;
                                this.accountValueSelected = accountOpt.value;
                                this.getQuarters();
                            }
                        } else if(this.checkForUndefinedEmptyAndNull(qrParams.accountId)&&  qrParams !={} && Object.keys(qrParams).length) {
                            this.accountNotLoaded = false;
                            this.accValueSelected = qrParams.accountId;
                            this.accountValueSelected = this.accountOptions.find(opt => opt.value === this.accValueSelected).label;
                            this.getQuarters();  
                        }
                    }else if(this.checkForUndefinedEmptyAndNull(qrParams.accountId)&&  qrParams !={} && Object.keys(qrParams).length){
                            this.accountNotLoaded = false;
                            
                            this.accValueSelected = qrParams.accountId;
                            this.accountValueSelected = this.accountOptions.find(opt => opt.value === this.accValueSelected).label;
                            this.template.querySelector('c-core_-m-d-f_-custom-lookup').selectPassedAccount(this.accValueSelected,this.accountValueSelected);
                            this.getQuarters();
                    }
                }
                this.isLoading = false;    
            })
            .catch(error => {
                this.isLoading = false;
                this.error = error;
                this.logErrorMessage(error);
            });
    }

    getQuarters() {
        let qrParams = this.queryParams;
        getQuarterPicklistValues()
            .then((data) => {
                if(this.checkForUndefinedEmptyAndNull(data)){
                    if (this.accValueSelected != null) {
                        this.quarterNotLoaded = false;
                        for (let i = 0; i < data.length; i++) {
                            this.quarterOptions = [...this.quarterOptions, { value: data[i], label: data[i] }];
                        }
                        console.log('quarter options',this.quarterOptions);
                        console.log('yest qrParams ',qrParams);
                        if(this.checkForUndefinedEmptyAndNull(qrParams.quarterYear)&&  qrParams !={} && Object.keys(qrParams).length) {
                            //this.allOptionsNotSelected = false;  

                            this.quarterSelected = qrParams.quarterYear;
                            this.quarterValueSelected = qrParams.quarterYear;
                            this.quarterValueSelected = this.quarterOptions.find(opt => opt.value === this.quarterValueSelected).label;
                            this.allOptionsNotSelected = false; 
                            qrParams.quarterYear = null;
                        }

                    }
                }
            })
            .catch(error => {
                this.error = error;
                this.logErrorMessage(error);
            });
    }

    
    handleAccountFilterChange(event){
        this.quarterOptions=[];
        this.template.querySelectorAll("[data-id='quarter']").forEach(each => {
            each.value = null;
        });
        this.allOptionsNotSelected = true;
        this.accValueSelected = event.detail;
        if(this.accValueSelected != undefined && this.accValueSelected != null){
            this.accountValueSelected = this.accValueSelected;
            this.getQuarters();
        }
        
    }

    handleProgramFilterChange(event) {
        let qrParams = this.queryParams;
        this.accountOptions = [];
        console.log('event.detail.value ',event.detail.value);
        //if(!this.isExternalUser){
        //to remove existing account value on program change
        qrParams.accountId = null;
        this.template.querySelector('c-core_-m-d-f_-custom-lookup').handleRemovePill(event);
        this.accValueSelected = null;
        //}
        this.accountQueryFilter = " Id = '' ";
        this.quarterOptions = [];
        this.quarterValueSelected = null;

        this.allOptionsNotSelected = true;
        this.programValueSelected = this.programOptions.find(opt => opt.value == event.detail.value).label;
        let programSelected = this.programOptions.find(opt => opt.value == event.detail.value).value;
        if(programSelected != undefined ){
            this.programSelectedId = programSelected;
        }
        this.getAccounts(this.programValueSelected);
        this.isLoading = true;
    }

    handleQuarterFilterChange(event) {
        this.quarterValueSelected = this.quarterOptions.find(opt => opt.value == event.detail.value).label;
        this.allOptionsNotSelected = false;
    }

    checkForUndefinedEmptyAndNull(input) {
        if (input !== undefined && input !== null && input !== "") {
            return true;
        }else {
            return false;
        }
    }
    
}