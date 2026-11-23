import { LightningElement,track,wire } from 'lwc';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import checkSPRules from '@salesforce/apex/Core_IPS_addEDQToProduct_LEX.checkSPRules'; // krishna

export default class Core_IPS_AddEDQToSPButton_Lex extends NavigationMixin(LightningElement) {
    recordId;
    showmsg = false;
    @track Message;
    connectedCallback(){
        this.checkConditions();
        
    }
    @track CurrentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.recordId = currentPageReference.state.recordId;
    }
    checkConditions(){
        this.showmsg = true;
        checkSPRules({recordId: this.recordId}).then(result=>{
            if(result=='Success'){
                   
                let URL = window.location.origin+'/lightning/n/Core_IPS_Add_EDQ_To_SP_LEX?c__recordId='+this.recordId;            
                this.Message = 'Redirecting to Environment Detail Question Page';
                setTimeout(function() {  window.open(URL,'_self');  }, 900);
            }
            else{
                console.log('Result',result);
                this.Message = result;
                console.log(this.Message);
                
            }
        })

    }
    goTOSPRecordPage(){
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Core_IPS_Supported_Product__c', // objectApiName is optional
                actionName: 'view'
            }
        });    
    }
}