import { LightningElement,track,api} from 'lwc';
import resetRecovery from 
    '@salesforce/apex/Core_MDF_RecoveryClaimReportViewCtrl.resetRecovery';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    
import dataResetMsg from '@salesforce/label/c.Core_MDF_DataResetMsg';    

export default class Core_MDF_RecoveryLayout extends LightningElement {

   
   @track progVal;
   @track acctVal;
   @track quarterVal;
   @track mode;
   @track loadleft;
   @track loadright;
   @track loading;

   @api selRec={data:null,errors:null};
    selectedRowsForRecovery = {};

    passToParent(event){
        
        this.progVal = event.detail.program;
        this.acctVal = event.detail.account;
        this.quarterVal = event.detail.quarter;
        this.mode = event.detail.mode;
        this.template.querySelector('c-core_-m-d-f_-recovery-claims').getClaimsBasedOnConditionsForUI(this.progVal,this.acctVal,this.quarterVal,this.mode);
        this.template.querySelector('c-core_-m-d-f_-recovery-report-view').getFilteredDataForClaimsToBeRecovered(this.progVal,this.acctVal,this.quarterVal);
        this.loadleft = true;this.loadright = true;this.loading=true;
    }

    handleRefreshApex(){
        this.template.querySelector('c-core_-m-d-f_-recovery-claims').reloadWire();
    }

    handleResetRecovery(event){
        if(event.detail != null || event.detail.length == 0){
            resetRecovery({program: this.progVal, account: this.acctVal, quarter: this.quarterVal}) 
            .then((result) => {
                if(result == 'success'){
                    this.template.querySelector('c-core_-m-d-f_-recovery-claims').reloadWire();
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: dataResetMsg,
                        variant: 'success',
                        mode: 'pester'
                    });
                    this.dispatchEvent(event);
                }else if (result == 'noData'){
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'No Recovery Data to Reset!!',
                        variant: 'error',
                        mode: 'pester'
                    });
                    this.dispatchEvent(event);
                }
             })
            .catch(error => {
                   
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Reset Failed!!',
                        variant: 'error',
                        mode: 'pester'
                    });
                    this.dispatchEvent(event);
                });
        }
        else{
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'No Data to Reset!!You are already seeing the default view.',
                variant: 'warning',
                mode: 'pester'
            });
            this.dispatchEvent(event);
        }
         
    }

    getloadleft(event){
        this.loadleft = event.detail;
        if(this.loadleft==false && this.loadright == false){this.loading=false;}
    }
    getloadright(event){
        this.loadright = event.detail;
        if(this.loadleft==false && this.loadright == false){this.loading=false;}
    }

    saveRecoveryRecord(event){
        this.selRec.data = event.detail.data;
        this.selRec.errors = event.detail.errors;

        this.template.querySelector('c-core_-m-d-f_-recovery-filter').getSaveData(this.selRec);
        
    }
}