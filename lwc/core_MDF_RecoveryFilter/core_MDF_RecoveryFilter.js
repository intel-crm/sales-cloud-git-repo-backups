import { LightningElement, track,api } from 'lwc';
import getProgPicklistValues from '@salesforce/apex/Core_MDF_RecoveryFilters.getProgramIdToNameMap';
import getAccountPicklistValues from '@salesforce/apex/Core_MDF_RecoveryFilters.getAccountIdToNameMap';
import getQuarterPicklistValues from '@salesforce/apex/Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsWithoutCurrentQuarter';
import checkMode from '@salesforce/apex/Core_MDF_RecoveryClaimReportViewCtrl.checkMode';
import save from '@salesforce/apex/Core_MDF_Recovery_Helper.saveRecoveryRequests';
import reocveryBatch from '@salesforce/apex/Core_MDF_RecoveryFilters.scheduleRecoveryBatch';
import checkRecoveryMode from '@salesforce/apex/Core_MDF_RecoveryClaimReportViewCtrl.checkRecoveryMode';
import getBudgetTypes from '@salesforce/apex/Core_MDF_RecoveryClaimReportViewCtrl.getRecoveryBT';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Custom Labels
import programLabel from '@salesforce/label/c.Core_MDF_Program';
import accountLabel from '@salesforce/label/c.Core_MDF_Channel_Partner';
import quarterLabel from '@salesforce/label/c.Core_MDF_Quarter';
import selectProgram from '@salesforce/label/c.Core_MDF_LWC_SelectProgram_Label';
import selectAccount from '@salesforce/label/c.Core_MDF_LWC_SelectAccount_Label';
import selectQuarter from '@salesforce/label/c.Core_MDF_LWC_SelectQuarter_Label';
import getDataLabel from '@salesforce/label/c.Core_MDF_GetData';
import saveLabel from '@salesforce/label/c.Core_MDF_Save';
import resetToDefault from '@salesforce/label/c.Core_MDF_ResetToDefault';
import defaultRecoveryMsg from '@salesforce/label/c.Core_MDF_RecoverDefaultMsg';
import resetToDefaultMsg from '@salesforce/label/c.Core_MDF_ResetToDefaultMsg';
import recoveryErrorMsg from '@salesforce/label/c.Core_MDF_RecoveryErrorMsg';
//import noBT from '@salesforce/label/c.Core_MDF_No_Budget_Types';
//import spcfProg from '@salesforce/label/c.Core_MDF_NonTranslateSPCFRecordType';


export default class Core_MDF_RecoveryFilter extends LightningElement {
    accountNotLoaded=true;
    quarterNotLoaded=true;
    allOptionsNotSelected = true;
    disableConfirm = false;
    //Custom Labels--start
    programLabel = programLabel;
    accountLabel = accountLabel;
    quarterLabel = quarterLabel;
    selectProgram = selectProgram;
    selectAccount = selectAccount;
    selectQuarter = selectQuarter;
    getDataLabel = getDataLabel;
    saveLabel = saveLabel;
    resetToDefault = resetToDefault;
    defaultRecoveryMsg = defaultRecoveryMsg;
    resetToDefaultMsg = resetToDefaultMsg;
    //Custom labels--end

    programOptions=[];
    accountOptions=[];
    quarterOptions=[];

    @track accountValueSelected='';
    @track programValueSelected='';
    @track quarterValueSelected='';
    @track mode='read';
    @track selectedBT='';
    @track filterValChanged = false;
    @track picklistOptions= [];
    @track isLoading = false;

    programSelected='';
    accValueSelected='';
    accountSelected='';
    quarterSelected='';
    isDisableButton  = true;
    isRecoveryDisabled = true;
    bypassSharing = true;
    
    isExternalUser =false;
    showRecoverClaims = false;
    showRecoveryConf = false;
    showRecoveryResult = false;
    showRecoveryClaimsBtn = false;
    getBT= true;
    accountQueryFilter = '';
    listOfAccIdsCommaSeparated='';
    

    @track selectedOptions = {account:this.accountValueSelected, program:this.programValueSelected, quarter:this.quarterValueSelected, mode: this.mode, budgetType: this.selectedBT};

    @api item={data:null,errors:null};
 
    connectedCallback() { 
        this.getPrograms();
    }

    getMode(program,account){
        checkMode({program: program, account: account}) 
        .then((data) => {
            this.mode = data;
            if(data == 'edit'){
                this.isDisableButton = false;
            }  
            else if(data == 'read'){
                this.isDisableButton = true;
            } 

            this.selectedOptions.program = program;
            this.selectedOptions.account = this.accountValueSelected;
            this.selectedOptions.quarter = this.quarterValueSelected;
            this.selectedOptions.mode = this.mode;
            const custEvent = new CustomEvent(
                'callpasstoparent', {
                    detail: this.selectedOptions
                });
            this.dispatchEvent(custEvent);
            this.filterValChanged = false;
          
         })
            .catch(error => {
                this.error = error;
               
                
            });
    }
    getPrograms() {
        getProgPicklistValues() 
        .then((data) => {
            for(let i=0; i<data.length; i++)  {
                this.programOptions = [...this.programOptions ,{value: data[i].progApiName , label: data[i].progname} ];                                   
            } 
            if(data[0].isExternal){
                this.isExternalUser = true;
                if(data.length == 1){
                    let programOpt = this.programOptions.find((sam,index) => index==0);
                    if(programOpt != undefined ){
                        //this.isExternalUser = true;
                        this.programSelected = programOpt.value;  
                        this.programValueSelected = programOpt.label;  
                        this.getAccounts(this.programValueSelected);
                    }
                    console.log('Print-> ',programOpt);
                }
            }
         })
            .catch(error => {
                this.error = error; 
            }); 
    }

    getAccounts(prog){
        this.isLoading = true;
        let accIds = [];
        getAccountPicklistValues({program:prog}) 
        .then((data) => {
            this.accountNotLoaded=false;

            //this.listOfAccIdsCommaSeparated = '(';
            for(let i=0; i<data.length; i++)  {
                if(!this.accountOptions.find(opt=> opt.value==data[i].accountId)){
                    accIds.push("'"+data[i].accountId+"'");
                    /*this.listOfAccIdsCommaSeparated = this.listOfAccIdsCommaSeparated +'\'' + data[i].accountId + '\'';//id in ('','')
                    if(i < data.length - 1){
                        this.listOfAccIdsCommaSeparated = this.listOfAccIdsCommaSeparated + ',';
                    }*/
                    this.accountOptions = [...this.accountOptions ,{value: data[i].accountId , label: data[i].accountName} ];                                   
                    
                }
                
	        }
	        if(data.length == 0){
                this.accountQueryFilter = " Id = '' ";
                this.isLoading = false; 
            }else{
                this.listOfAccIdsCommaSeparated = '(' + accIds + ')';
                this.accountQueryFilter = " Id In "+this.listOfAccIdsCommaSeparated + ' order by Name';
                this.isLoading = false; 
            }
            if(data[0].isExternal){
                this.isExternalUser = true;
            
                if(data.length == 1){
                    let accountOpt = this.accountOptions.find((sam,index) => index==0);
                    if(accountOpt != undefined ){
                        //this.isExternalUser = true;
                        this.template.querySelector('c-core_-m-d-f_-custom-lookup').selectAccountOnRecoveryIfOneAccOnly(data);
                        this.accValueSelected = accountOpt.value;  
                        this.accountValueSelected = accountOpt.value;  
                        this.getQuarters();
                    }
                }
            }
          
         })
            .catch(error => {
                this.isLoading = false; 
                this.error = error;
            }); 
    }

    getQuarters(){
        getQuarterPicklistValues() 
        .then((data) => {
            
            if(this.accValueSelected != null){
                this.quarterNotLoaded=false;
                for(let i=0; i<data.length; i++)  {
                    this.quarterOptions = [...this.quarterOptions ,{value: data[i] , label: data[i]} ];                                   
                }
            }    
         })
            .catch(error => {
                this.error = error; 
            }); 
    }

    handleAccountFilterChange(event){
        this.filterValChanged = true;
        this.isDisableButton = true;
        this.isRecoveryDisabled = true;
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

    handleProgramFilterChange(event){
        this.filterValChanged = true;
        this.isDisableButton = true;
        this.isRecoveryDisabled = true;
        this.accountOptions=[];

        //if(!this.isExternalUser){
            //to remove existing account value on program change
            this.template.querySelector('c-core_-m-d-f_-custom-lookup').handleRemovePill(event);
            this.accValueSelected = null;
        //}
        this.accountQueryFilter = " Id = '' ";
        this.quarterOptions=[];
        this.template.querySelectorAll("[data-id='quarter']").forEach(each => {
            each.value = null;
        });
        
        this.allOptionsNotSelected = true;
        this.programValueSelected = this.programOptions.find(opt=> opt.value==event.detail.value).label;
        this.getAccounts(this.programValueSelected);
    }

    handleQuarterFilterChange(event){
        this.filterValChanged = true;
        this.isDisableButton = true;
        this.isRecoveryDisabled = true;
        this.quarterValueSelected = this.quarterOptions.find(opt=> opt.value==event.detail.value).label;
        this.allOptionsNotSelected = false;
    }

    @api getSaveData(saveData){
        this.item = saveData;
        if(this.item.data != null && this.mode == 'edit'){
            this.isDisableButton = false;
        }else{
            this.isDisableButton = true;
        }
        checkRecoveryMode({program : this.programValueSelected})
        .then((data) => {
            if(data === true && this.item.data != null){
                this.isRecoveryDisabled = false;
                this.showRecoveryClaimsBtn = true;
            }  
            else{
                this.isRecoveryDisabled = true;
            }
         })
            .catch(error => {
                this.error = error;
            });
    }

    handleSave(){
        if(this.item.errors>0){
            const event = new ShowToastEvent({
                title: 'Error',
                message: recoveryErrorMsg,
                variant: 'error',
                mode: 'pester'
            });
            this.dispatchEvent(event);
        }
        else{
            if(this.item.data != null ){
            if(this.item.data.length == 0){
                this.popupMsgFromSave = true;
                this.handleResetToOriginal();
            }
            else{
                this.popupMsgFromSave = false;
                save({rrr: this.item.data}) 
                .then((data) => {
                    const custEvent = new CustomEvent(
                        'refreshapexdata');
                    this.dispatchEvent(custEvent);
                    var saveRes = JSON.parse(JSON.stringify(data));
                    if(saveRes == null){
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'Save Failed! Please try again later.',
                            variant: 'error',
                            mode: 'pester'
                        });
                        this.dispatchEvent(event);  
                    }
                    else{
                        for(var key in saveRes){
                            if(key == "true"){
                                const event = new ShowToastEvent({
                                    title: 'Success',
                                    message: saveRes[key],
                                    variant: 'success',
                                    mode: 'pester'
                                });
                                this.dispatchEvent(event);
                            }
                            else if(key == "false"){
                                const event = new ShowToastEvent({
                                    title: 'Error',
                                    message: saveRes[key],
                                    variant: 'error',
                                    mode: 'sticky'
                                });
                                this.dispatchEvent(event);
                            }
                             
                        }
                    }
                 })
                    .catch(error => {
                        this.error = error;
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: this.error,
                            variant: 'error',
                            mode: 'pester'
                        });
                        this.dispatchEvent(event);
                        
                    });
            }
        }
        } 
    }

   isShowResetConfirmation = false;
    handleResetToOriginal(){
        this.isShowResetConfirmation = true;
         
    }
    closeModal(){
        this.isShowResetConfirmation = false;
        this.popupMsgFromSave = false;
        this.showRecoverClaims = false;
        this.showRecoveryResult = false;
        this.showRecoveryConf = false;
    }

    handleResetRecovery(){
        const custEvent = new CustomEvent(
            'resetrecoveryrecord',{
                detail: this.item.data
            });
        this.dispatchEvent(custEvent);
        this.isShowResetConfirmation = false;
        this.popupMsgFromSave = false;
    }

    getData(){
       
        this.item={data:null,errors:null};
        var program = this.programOptions.find(opt=> opt.label==this.programValueSelected).value;
        this.getMode(program,this.accountValueSelected);
        
    }

    recoverClaims(){
        /*var noBTArray = noBT.split(";");
        if(noBT.includes(this.selectedOptions.program)){
            for(const key in noBTArray){
                if(noBTArray[key] == this.selectedOptions.program && noBTArray[key] != spcfProg){
                    this.showRecoverClaims = false;
                    this.showRecoveryConf = true;
                    this.getBT = false; break;
                }
                else{
                    this.getBT = true;
                }
            }    
        }*/
        if(this.getBT==true){
            //this.showRecoverClaims = true;
            getBudgetTypes({program: this.selectedOptions.program, account: this.selectedOptions.account, quarter: this.selectedOptions.quarter})
            .then((data) => {
            var budgetTypes = [];
            budgetTypes = data;
            var tempOptions = [];
            for(const key in budgetTypes){
                if(budgetTypes[key] === 'None'){
                    this.showRecoverClaims = true;
                    this.disableConfirm = true;
                }else{
                    this.showRecoverClaims = true;
                    this.disableConfirm = false;
                }
               const obj = {
                label: budgetTypes[key],
                value: budgetTypes[key],
            };
            tempOptions = [...tempOptions, obj];
            } 
            this.picklistOptions = tempOptions; 
            })
            .catch(error => {
                this.error = error; 
            });
        }     
    }
    
    handleBTSelect(event){
        if(event.target.value === this.selectedOptions.program){
            this.selectedBT = '';
        }else{
            this.selectedBT = event.target.value;
        }
    }
    
    confirmRecovery(){
        var allComboValid = false;
        allComboValid = [...this.template.querySelectorAll('lightning-combobox')]
			.reduce((validSoFar, inputCmp) => {
				inputCmp.reportValidity();
				return validSoFar && inputCmp.checkValidity();
			}, true);
        if(allComboValid){
            this.showRecoverClaims = false;
            this.showRecoveryConf = true;
        }
    }

    handleRecovery(){
        this.showRecoveryConf = false;
        this.selectedOptions.budgetType = this.selectedBT;
        reocveryBatch({wrapper:this.selectedOptions})
        .then(result => {
            this.showRecoveryResult = true;
            if(result === true){
                this.popupMsgFromRecoveryBatch=true;
            }
            else{
                this.popupMsgFromRecoveryBatch=false;
            }
        }) .catch(error => {
            this.showRecoveryResult = true;
            this.popupMsgFromRecoveryBatch=false;
            this.error = error;
        });
    }
}