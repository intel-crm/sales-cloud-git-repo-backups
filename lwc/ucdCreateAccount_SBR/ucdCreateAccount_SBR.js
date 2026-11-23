import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';


export default class UcdCreateAccount_SBR extends NavigationMixin(LightningElement) {
    @api acctformdetails; 
    @api objectApiName="Account";
    @track industryOptions;
    @track subindustryOptions;
    @track bizorgOptions;
    @track accId;
    @track loaded=false;
    @track errorMsg;
    accountId;
    @track permissionErrorCode=0;
    @track submitError;
    @track errorList;
    @track detailid;
   
    handleSubmit(event) {
        if(this.permissionErrorCode!=1){
          this.validateFields();
        }
                    
    }
    handleSuccess(event) {
        this.loaded=false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
              recordId: event.detail.id,
              objectApiName: 'Account',
              actionName: 'view'
            },
          });
    }
    handleError(event) {
        console.log('Inside handle error'+JSON.stringify(event.detail));
        this.loaded=false; 
        if(JSON.stringify(event.detail.detail)==='""'){
            console.log('Inside if'+event.detail.detail);
            this.permissionErrorCode=1;
            this.errorMsg='You do not have suffient access to create a record!';                                      
        }
        else{
            console.log('Inside else'+event.detail.detail);
            this.errorMsg=JSON.stringify(event.detail.detail);            
        }
        const eve = new ShowToastEvent({
                    variant: 'error',
                    title: 'Error!',
                    message: this.errorMsg,
                });
                this.dispatchEvent(eve); 
    }
    
    handleBackButtonClick(event) {
        console.log('inside create account '+JSON.stringify(this.acctformdetails));
        const acctCreateBackClick = new CustomEvent("acctcreatebackclick", { detail: this.acctformdetails });
        this.dispatchEvent(acctCreateBackClick);       
    }

    validateFields(){
        this.submitError='' ;
        this.errorList='';
        // this.template.querySelectorAll('lightning-input-field').forEach(element => {
        //     element.reportValidity();
        // });
        this.errorList=((!this.template.querySelector(".Name").value)?(this.submitError+',' +'Account Name'):'') +
        ((!this.template.querySelector(".AccType").value)?(this.submitError+',' +'Biz Org Type'):'') +
        ((!this.template.querySelector(".Industry").value)?(this.submitError+',' +'Industry'):'') +
        ((!this.template.querySelector(".SubIndustry").value)?(this.submitError+',' +'SubIndustry'):'') +
        ((!this.template.querySelector(".BillingCountry").value)?(this.submitError+',' +'BillingCountry'):'') +
        ((!this.template.querySelector(".BillingStreet").value)?(this.submitError+',' +'BillingStreet'):'') +
        ((!this.template.querySelector(".BillingCity").value)?(this.submitError+',' +'BillingCity'):'')
      
        if (this.acctformdetails.stateOpt.length>0 && this.acctformdetails.stateOpt.length != undefined){
            this.submitError=this.errorList+((!this.template.querySelector(".BillingState").value)?(this.submitError+',' +'BillingState'):'');            
        }
        else{
            this.submitError=this.errorList;
        }

        if(this.submitError!=''){
            const eve = new ShowToastEvent({
                        variant: 'error',
                        title: 'Error!',
                        message: 'Review the required fields errors! '+this.submitError,
                    });
                    this.dispatchEvent(eve);   
                                                            
        } 
        else{           
            this.loaded=true;
        } 
    }
    
}